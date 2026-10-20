// § thisNetFirstListingModule418
import p::*;
module sub (input logic a);
endmodule
module top;
  logic x;
  sub u (.a(x));
endmodule
