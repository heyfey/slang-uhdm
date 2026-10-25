// § structMemberDefaultParamRef430
module top ();
parameter c = 32'd7;
initial begin
  struct { int lo = c; } p1;
  $display(p1.lo);
end
endmodule
