test__blk_sectors_str: .string "Sectors: %u\n\r"
test__blk_block_size_str: .string "Block_size: %u\n\r"

test__hello_world_str: .string "Hello World!\n\r"

#test__test_string: .string "\x1B[3;4H\x1B[92;46;7mHello\n\x1B[27;31;103m\x1b[13;5HWorld\x1b[H\x1b[K"
#test__test_string: .string "\x1b[4hHello world\nDoes This Work\x1b[1A\r\x1b[91;7mGood Bye\x1b[0m\n\n"
test__test_string: 
.string "\x1b[7;96mH"

test__test_string_2: 
.string "\n"

test__test_string_3: 
.string "\x1b[0;31mW"

test__test_string_4: 
.string "\x1b[1;1H"

test__path: .string "/"#helloworld"
