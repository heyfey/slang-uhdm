// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5;
for (genvar i = 0; i < 2; i++) begin : g
  struct { bit [3:0] lo = c; } p1;
end
endmodule
