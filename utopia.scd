~addrBook = AddrBook.new;
~addrBook.addMe;
~hail = Hail.new(~addrBook);
~objSpace = OSCObjectSpace(~addrBook, oscPath:'/gui');