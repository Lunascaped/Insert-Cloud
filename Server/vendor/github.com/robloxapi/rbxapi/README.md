[![GoDoc](https://godoc.org/github.com/RobloxAPI/rbxapi?status.png)](https://godoc.org/github.com/RobloxAPI/rbxapi)

# rbxapi

The rbxapi package is a Go package used to represent information about the
Roblox Lua API.

## API References

- [rbxapi](https://godoc.org/github.com/RobloxAPI/rbxapi)
	- [patch](https://godoc.org/github.com/RobloxAPI/rbxapi/patch): Used to represent information about differences between Roblox Lua API structures.
	- [diff](https://godoc.org/github.com/RobloxAPI/rbxapi/diff): Provides an implementation of the patch package for the generic rbxapi types.
- [rbxapidump](https://godoc.org/github.com/RobloxAPI/rbxapi/rbxapidump): Implements the rbxapi interface as a codec for the Roblox API dump format.
- [rbxapijson](https://godoc.org/github.com/RobloxAPI/rbxapi/rbxapijson): Implements the rbxapi package as a codec for the Roblox API dump in JSON format.
	- [diff](https://godoc.org/github.com/RobloxAPI/rbxapi/rbxapijson/diff): Provides an implementation of the patch package for the rbxapijson types.
