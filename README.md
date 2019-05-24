HAMT (for Swift)
=============
An implementation of [*HAMT(Hash Array Mapped Trie)*](https://en.wikipedia.org/wiki/Hash_array_mapped_trie) in Swift.
Eonil, May 2019.



Getting Started
------------------
Use `HAMT` type. This type implements typical dictionary-like members.



Performance
----------------
`HAMT` is designed to be used as
[*persistent datastructure*](https://en.wikipedia.org/wiki/Persistent_data_structure).

`HAMT` provides near constant time (`O(machine word size)`) performance up to 
hash resolution limit (`(2^6)^10` items) for read/write/copy regardless of item count
where copying `Swift.Dictionary` takes linearly increased time.

Base performance of `HAMT` is about 10x times slower than ephemeral `Swift.Dictionary`.

![Get Performance](PerfTool/Get.png)

Therefore, `HAMT` performs better if your dataset potentially can grow more than
several thousands.

Here's another performance comparison with copying B-Tree. 
Copying naive `Swift.Dictionary` is not here because it takes too much time 
and couldn't finish the benchmark.

![CRUD Performance](PerfTool/CRUD.png)







Maintenance
---------------
`HAMT` type is internally implemented using `PD5Bucket64` internal type.
`PD5Bucket64` type provides all additional properties for testing and
validation.
`PD4` type was an implementation of hash-trie, and deprecated due to
high rate of wasted memory. `PD5` implements HAMT and shows nearly
same performance with `PD4` with far less memory consumption.




Caution!
----------
If you link this library, you'll notice the performance is not good as shown 
in the graph. [As like Károly Lőrentey clarified](https://github.com/attaswift/BTree#generics),
it's because Swift compiler does not inline externally linked functions.
You can compile HAMT source code with your code togather to archive
best possible performance.




Credits
---------
- See also ["B-Tree for Swift" by Károly Lőrentey](https://github.com/attaswift/BTree) 
if you need sorted associative array.

- Here's a [nice explanation](https://idea.popcount.org/2012-07-25-introduction-to-hamt/) 
of how HAMT works by Marek.

- For more information about HAMT, see
[the paper by Phil Bagwell](https://infoscience.epfl.ch/record/64398/files/idealhashtrees.pdf).



Contribution
---------------
Any contributions are welcome, and sending contribution means you agreed to redistribute
your contribution code under "MIT License".



License
---------
This code is licensed under "MIT License".
Copyright Eonil, Hoon H.. 2019.
All rights reserved.
