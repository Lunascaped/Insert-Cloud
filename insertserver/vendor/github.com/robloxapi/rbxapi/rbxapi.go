// The rbxapi package is used to represent information about the Roblox Lua
// API.
//
// This package provides a common interface for multiple implementations of
// the Roblox Lua API. The rbxapi interface may not be able to expose all
// information available from a particular implementation. If such information
// is required, it would be more suitable to use that implementation directly.
//
// The rbxapidump and rbxapijson subpackages provide implementations of the
// rbxapi interface.
package rbxapi

// Root represents the top-level structure of an API.
type Root interface {
	// GetClasses returns a list of class descriptors present in the API.
	// Items in the list must have a consistent order.
	GetClasses() []Class

	// GetClass returns the first class descriptor of the given name, or nil
	// if no class of the given name is present.
	GetClass(name string) Class

	// GetEnums returns a list of enum descriptors present in the API. Items
	// in the list must have a consistent order.
	GetEnums() []Enum

	// GetEnum returns the first enum descriptor of the given name, or nil if
	// no enum of the given name is present.
	GetEnum(name string) Enum

	// Copy returns a deep copy of the API structure.
	Copy() Root
}

// Class represents a class descriptor.
type Class interface {
	// GetName returns the class name.
	GetName() string

	// GetSuperclass returns the name of the class that this class inherits
	// from.
	GetSuperclass() string

	// GetMembers returns a list of member descriptors belonging to the class.
	// Items in the list must have a consistent order.
	GetMembers() []Member

	// GetMember returns the first member descriptor of the given name, or nil
	// if no member of the given name is present.
	GetMember(name string) Member

	// Copy returns a deep copy of the class descriptor.
	Copy() Class

	Taggable
}

// Member represents a class member descriptor. A Member can be asserted to a
// more specific type. These are Property, Function, Event, and Callback.
type Member interface {
	// GetMemberType returns a string indicating the the type of member.
	GetMemberType() string

	// GetName returns the name of the member.
	GetName() string

	// Copy returns a deep copy of the member descriptor.
	Copy() Member

	Taggable
}

// Property represents a class member of the Property member type.
type Property interface {
	Member

	// GetSecurity returns the security context associated with the property's
	// read and write access.
	GetSecurity() (read, write string)

	// GetValueType returns the type of value stored in the property.
	GetValueType() Type
}

// Function represents a class member of the Function member type.
type Function interface {
	Member

	// GetSecurity returns the security context of the member's access.
	GetSecurity() string

	// GetParameters returns the list of parameters describing the arguments
	// passed to the function. These parameters may have default values.
	GetParameters() Parameters

	// GetReturnType returns the type of value returned by the function.
	GetReturnType() Type
}

// Event represents a class member of the Event member type.
type Event interface {
	Member

	// GetSecurity returns the security context of the member's access.
	GetSecurity() string

	// GetParameters returns the list of parameters describing the arguments
	// received from the event. These parameters cannot have default values.
	GetParameters() Parameters
}

// Callback represents a class member of the Callback member type.
type Callback interface {
	Member

	// GetSecurity returns the security context of the member's access.
	GetSecurity() string

	// GetParameters returns the list of parameters describing the arguments
	// passed to the callback. These parameters cannot have default values.
	GetParameters() Parameters

	// GetReturnType returns the type of value that is returned by the
	// callback.
	GetReturnType() Type
}

// Parameters represents a list of parameters of a function, event, or
// callback member.
type Parameters interface {
	// GetLength returns the number of parameters in the list.
	GetLength() int

	// GetParameter returns the parameter indicated by the given index.
	GetParameter(int) Parameter

	// GetParameters returns a copy of the list as a slice.
	GetParameters() []Parameter

	// Copy returns a deep copy of the parameter list.
	Copy() Parameters
}

// Parameter represents a single parameter of a function, event, or callback
// member.
type Parameter interface {
	// GetType returns the type of the parameter value.
	GetType() Type

	// GetName returns the name describing the parameter.
	GetName() string

	// GetDefault returns a string representing the default value of the
	// parameter, and whether a default value is present.
	GetDefault() (value string, ok bool)

	// Copy returns a deep copy of the parameter.
	Copy() Parameter
}

// Enum represents an enum descriptor.
type Enum interface {
	// GetName returns the name of the enum.
	GetName() string

	// GetEnumItems returns a list of items of the enum. Items in the list
	// must have a consistent order.
	GetEnumItems() []EnumItem

	// GetEnumItem returns the first item of the given name, or nil if no item
	// of the given name is present.
	GetEnumItem(name string) EnumItem

	// Copy returns a deep copy of the enum descriptor.
	Copy() Enum

	Taggable
}

// EnumItem represents an enum item descriptor.
type EnumItem interface {
	// GetName returns the name of the enum item.
	GetName() string

	// GetValue returns the value of the enum item.
	GetValue() int

	// Copy returns a deep copy of the enum item descriptor.
	Copy() EnumItem

	Taggable
}

// Taggable indicates a descriptor that is capable of having tags.
type Taggable interface {
	// GetTag returns whether the given tag is present in the descriptor.
	GetTag(tag string) bool

	// GetTags returns a list of all tags present in the descriptor. Items in
	// the list must have a consistent order.
	GetTags() []string
}

// Type represents a value type.
type Type interface {
	// GetName returns the name of the type.
	GetName() string

	// GetCategory returns the category of the type. This may be empty when a
	// type category is inapplicable or unavailable.
	GetCategory() string

	// String returns a string representation of the entire type. The format
	// of this string is implementation-dependent.
	String() string

	// Copy returns a deep copy of the type.
	Copy() Type
}
