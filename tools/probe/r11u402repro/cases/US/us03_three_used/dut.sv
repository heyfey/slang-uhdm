// § anonUnpackedStructSlotEnd402
module top ();
struct { logic x; int y; byte z; } s;
initial s.y = 1;
endmodule
