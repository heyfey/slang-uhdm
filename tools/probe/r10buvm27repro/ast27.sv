module t;
  byte b8; bit [31:0] v32; byte dyn[]; int r;
  initial begin
    r = $bits(b8);
    r = $bits(b8 & v32);
    r = $bits(dyn[0] & b8);
  end
endmodule
