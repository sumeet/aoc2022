import Foundation

class Dir {
    var subdirByName: [String: Dir]
    var fileSizeByName: [String: Int]
    var parent: Dir?

    init(parent: Dir?) {
        self.parent = parent
        self.subdirByName = [:]
        self.fileSizeByName = [:]
    }

    func addFileSize(name: String, size: Int) {
        fileSizeByName[name] = size
    }

    func childDir(name: String) -> Dir {
        if let dir = subdirByName[name] {
            return dir
        } else {
            let dir = Dir(parent: self)
            subdirByName[name] = dir
            return dir
        }
    }

    func totalSize() -> Int {
        var total = 0
        for (_, size) in fileSizeByName {
            total += size
        }

        for (_, dir) in subdirByName {
            total += dir.totalSize()
        }

        return total
    }

    func walkChildrenIncludingSelf(_ f: (Dir) -> Void) {
        f(self)
        for (_, dir) in subdirByName {
            dir.walkChildrenIncludingSelf(f)
        }
    }
}

var root = Dir(parent: nil)
var pwd = root;

// read input from "input.txt" in linux on swift
let input = try! String(contentsOfFile: "input.txt")
var lines = input.split(separator: "\n")

var lineI = 0;

while (lineI < lines.count) {
    let line = lines[lineI]

    if line.starts(with: "$ cd") {
        let dir = String(line.split(separator: " ")[2])
        if dir == ".." {
            pwd = pwd.parent!
        } else if dir == "/" {
            pwd = root
        } else {
            pwd = pwd.childDir(name: dir) 
        }

        lineI += 1
        continue
    } else if line.starts(with: "$ ls") {
        lineI += 1

        while (lineI < lines.count) {
            let line = lines[lineI]
            if line.starts(with: "$") {
                lineI -= 1
                break
            // ignore "dir"
            } else if line.starts(with: "dir") {
                lineI += 1
            } else {
                let parts = line.split(separator: " ")
                let size = Int(parts[0])!
                let filename = String(parts[1])
                pwd.addFileSize(name: filename, size: size)
                lineI += 1
            }
        }
        continue
    }
    
    lineI += 1
}

var total = 0
let max_size = 100_000
root.walkChildrenIncludingSelf { dir in
    let dirSize = dir.totalSize()
    if dirSize <= max_size {
        total += dirSize
    }
}
print(total)