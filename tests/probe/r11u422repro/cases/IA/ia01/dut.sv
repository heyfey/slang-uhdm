// § arrayElemConcatConnWhole422
module driver (in, out, en);
input [3:0] in;
output [3:0] out;
input en;
bufif0 ar[3:0] (out, in, en);
endmodule
module top (busin, bushigh, buslow, enh, enl);
input [15:0] busin;
output [7:0] bushigh, buslow;
input enh, enl;
driver busar[3:0] (.out({bushigh, buslow}), .in(busin),
.en({enh, enh, enl, enl}));
endmodule
