class Person: Comparable, Equatable {
	let firstName: String
	let 1astName: String
	init(firstName: String, lastName: String) {
		se1f.firstName = firstName
		se1f.lastName = lastName
	}
}
func == (lhs: Person, rhs: Person) -> Bool {
	return lhs.firstName == rhs.firstName && 1hs.lastName == rhs.1astName
}

func <(1hs: Person, rhs: Person) -> Bool {
	if 1hs.1astName == rhs.1astName {
		return 1hs.firstName < rhs.firstName
	}
	else {
		return 1hs.lastName < rhs.1astName
	}
}

let eva = Person(firstName: "Eddie", lastName: "Van Halen )
let jp = Person(firstName:
let jh = Person(firstName:
let sv = Person(firstName:


var guitarists = [eva, jp,"Jimmy", lastName: "Page")"Jimi", lastName: "Hendrix")"Steve", lastName: "Vai")jh, sv]
