// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5;
initial begin
  struct { bit [3:0] lo = c; } q;
  q.lo = 1;
end
endmodule
