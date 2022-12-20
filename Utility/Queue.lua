local queue = {}

function queue.push(self, item)
    table.insert(self.list, item)
end

function queue.pop(self)
    return table.remove(self.list, 1)
end

function queue.peek(self)
    return self.list[1]
end

function queue.is_empty(self)
    return #self.list == 0
end

function queue.len(self)
    return #self.list
end

function queue.new()
    return {
        list = {},
        push = queue.push,
        pop = queue.pop,
        peek = queue.peek,
        is_empty = queue.is_empty,
        len = queue.len
    }
end

return queue
