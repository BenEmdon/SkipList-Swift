//
//  main.swift
//  SkipList
//
//  Created by Benjamin Emdon on 2016-11-06.
//


import Foundation

public class SkipListNode<T> {
	var value: T?
	var next: [SkipListNode?]
	var edgeLength: [Int]

	public init(value: T?, height: Int) {
		self.value = value
		next = [SkipListNode?](repeating: nil, count: height + 1)
		edgeLength = [Int](repeating: 0, count: height + 1)
	}

	public var height: Int {
		return next.count - 1
	}
}

public class SkipList<T> {
	public typealias Node = SkipListNode<T>

	fileprivate let sentinal = Node(value: nil, height: 32)

	fileprivate var height: Int = 0

	fileprivate var numberOfElements: Int = 0

	public init() {}

	public var count: Int {
		return numberOfElements
	}

	fileprivate func findPreceding(index: Int) -> Node {
		var node = sentinal
		var verticalIndex = height
		var horizontalIndex = -1
		while verticalIndex >= 0 {
			while (node.next[verticalIndex] != nil) &&
				horizontalIndex + node.edgeLength[verticalIndex] < index {
					horizontalIndex += node.edgeLength[verticalIndex]
					node = node.next[verticalIndex]!
			}
			verticalIndex -= 1
		}
		return node
	}

	public subscript(index: Int) -> T {
		return findPreceding(index: index).next[0]!.value!
	}

	public func set(index: Int, value: T) -> T {
		let node = findPreceding(index: index).next[0]!
		let oldValue = node.value
		node.value = value
		return oldValue!
	}

	fileprivate func insert(index: Int, newNode: Node) -> Node {
		var node = sentinal
		var verticalIndex = height
		var horizontalIndex = -1
		while verticalIndex >= 0 {
			while (node.next[verticalIndex] != nil) &&
				horizontalIndex + node.edgeLength[verticalIndex] < index {
					horizontalIndex += node.edgeLength[verticalIndex]
					node = node.next[verticalIndex]!
			}
			node.edgeLength[verticalIndex] += 1
			if verticalIndex <= newNode.height {
				newNode.next[verticalIndex] = node.next[verticalIndex]
				node.next[verticalIndex] = newNode
				newNode.edgeLength[verticalIndex] = node.edgeLength[verticalIndex] - (index - horizontalIndex)
				node.edgeLength[verticalIndex] = index - horizontalIndex
			}
			verticalIndex -= 1
		}
		numberOfElements += 1
		return node
	}

	fileprivate func pickHeight() -> Int {
		let randomNumber: UInt32 = arc4random()
		var height = 0
		var shiftCounter: UInt32 = 0
		while (randomNumber & shiftCounter) != 0 {
			height += 1
			shiftCounter <<= 1
		}
		return height
	}

	public func insert(index: Int, value: T?) {
		let node = Node(value: value, height: pickHeight())
		if node.height > height {
			height = node.height
		}
		insert(index: index, newNode: node)
	}

	public func remove(index: Int) -> T? {
		var value: T? = nil
		var node = sentinal
		var verticalIndex = height
		var horizontalIndex = -1
		while verticalIndex >= 0 {
			while (node.next[verticalIndex] != nil) &&
				horizontalIndex + node.edgeLength[verticalIndex] < index {
					horizontalIndex += node.edgeLength[verticalIndex]
					node = node.next[verticalIndex]!
			}
			node.edgeLength[verticalIndex] -= 1
			if horizontalIndex + node.edgeLength[verticalIndex] + 1 == index && node.next[verticalIndex] != nil {
				value = node.next[verticalIndex]!.value
				node.edgeLength[verticalIndex] += node.next[verticalIndex]!.edgeLength[verticalIndex]
				node.next[verticalIndex] = node.next[verticalIndex]!.next[verticalIndex]
				if node === sentinal && node.next[verticalIndex] == nil {
					height -= 1
				}
			}
			verticalIndex -= 1
		}
		numberOfElements -= 1
		return value
	}
}

extension SkipList: CustomStringConvertible {
	public var description: String {
		var s = "["
		var node = sentinal.next[0]
		while node != nil {
			s += "\(node!.value!)"
			node = node!.next[0]
			if node != nil { s += ", " }
		}
		return s + "]"
	}
}

//let list = SkipList<Int>()
//list.insert(index: 0, value: 0)
//list.insert(index: 1, value: 0)
//list.insert(index: 2, value: 3)
//list.insert(index: 0, value: 3)
//print(list.description)
