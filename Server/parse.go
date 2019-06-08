package lib

import (
	"errors"
	"fmt"
	"io"
	"math"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/robloxapi/rbxfile"
	"github.com/robloxapi/rbxfile/bin"
	"github.com/robloxapi/rbxfile/json"
)

//ErrFileTooBig An error in which the download url file exceeds 100 megabytes, or 1x10^8 bytes.
var ErrFileTooBig = errors.New("File size exceeds 100 megabytes or FileSize error")

//DownloadFile Borrowed from golangcode.com
func DownloadFile(id string) (io.Reader, error) {

	url := "https://www.roblox.com/asset?id=" + id

	filepath := id + ".rbxm"

	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return nil, err
	}
	defer out.Close()

	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Create a new buffer
	//buffer := bytes.NewBuffer(make([]byte, 2, 52))

	// Write the body to file
	_, err = io.Copy(out, resp.Body)
	if err != nil {
		return nil, err
	}

	// Open file as io.Reader
	file, err := os.Open(filepath)
	if err != nil {
		return nil, err
	}

	return file, nil
}

//PurifyFloat64Value Purifies float value as float64
func PurifyFloat64Value(Val float64) float64 {
	ReturnVal := Val
	if math.IsInf(Val, 0) {
		ReturnVal = 1000000000000
	} else if math.IsInf(Val, -1) {
		ReturnVal = -1000000000000
	} else if math.IsNaN(Val) {
		fmt.Println("nan")
		ReturnVal = 0
	}
	return ReturnVal
}

//PurifyFloat32Value Purifies float value as float32
func PurifyFloat32Value(Val float32) float32 {
	ReturnVal := Val
	FloatVal := float64(Val)
	if math.IsInf(FloatVal, 0) {
		ReturnVal = 1000000000000
	} else if math.IsInf(FloatVal, -1) {
		ReturnVal = -1000000000000
	} else if math.IsNaN(FloatVal) {
		ReturnVal = 0
	}
	return ReturnVal
}

//Purify Cleans a struct for +Inf or nan, sorry for the spaghetti code
func Purify(Obj *rbxfile.Instance) {
	for _, Inst := range Obj.Children {
		for Prop, PropVal := range Inst.Properties {
			NewVal := PropVal.String()
			ValType := PropVal.Type()
			if Val, err := strconv.ParseFloat(NewVal, 64); err == nil {
				ReturnVal := PurifyFloat64Value(Val)
				Inst.Properties[Prop] = rbxfile.ValueFloat(ReturnVal)
			} else if ValType == rbxfile.TypeVector3 {
				SplitString := strings.Split(NewVal, ", ")
				XStr := SplitString[0]
				YStr := SplitString[1]
				ZStr := SplitString[2]
				XVal, errX := strconv.ParseFloat(XStr, 32)
				YVal, errY := strconv.ParseFloat(YStr, 32)
				ZVal, errZ := strconv.ParseFloat(ZStr, 32)
				if errX == nil && errY == nil && errZ == nil {
					XFloat := PurifyFloat32Value(float32(XVal))
					YFloat := PurifyFloat32Value(float32(YVal))
					ZFloat := PurifyFloat32Value(float32(ZVal))
					Inst.Properties[Prop] = rbxfile.ValueVector3{
						X: XFloat,
						Y: YFloat,
						Z: ZFloat,
					}
				}
			} else if ValType == rbxfile.TypeVector2 {
				SplitString := strings.Split(NewVal, ", ")
				XStr := SplitString[0]
				YStr := SplitString[1]
				XVal, errX := strconv.ParseFloat(XStr, 32)
				YVal, errY := strconv.ParseFloat(YStr, 32)
				if errX == nil && errY == nil {
					XFloat := PurifyFloat32Value(float32(XVal))
					YFloat := PurifyFloat32Value(float32(YVal))
					Inst.Properties[Prop] = rbxfile.ValueVector2{
						X: XFloat,
						Y: YFloat,
					}
				}
			}
		}
		Purify(Inst)
	}
}

//Parse Downloads RBXM file with an asset id, parses through, and returns JSON table.
func Parse(id string) []byte {
	serializer := bin.NewSerializer(nil, nil)

	// Downloads file
	file, err := DownloadFile(id)
	if err != nil {
		fmt.Println(err)
		return nil
	}

	// Deserilization
	root, err := serializer.Deserialize(file)
	if err != nil {
		fmt.Println(err)
		return nil
	}

	// Purification (Makes sure the right values are there)
	for _, Inst := range root.Instances {
		Purify(Inst)
	}

	// JSON Encode
	marsh, err := json.Encode(root)
	if err != nil {
		fmt.Println(err)
		return nil
	}

	//output := string(marsh)
	return marsh
}
