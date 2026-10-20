// § thisNetFirstListingModule418
import p::*;
module bsub (input logic a);
endmodule
module asub (input logic a);
endmodule
module top;
  logic x;
  bsub u (.a(x));
  asub v (.a(x));
endmodule
