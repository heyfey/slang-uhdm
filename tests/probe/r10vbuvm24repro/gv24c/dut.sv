// r10vbuvm24repro/gv24c.sv — DPI import with defaulted formals.
module dpiv24;
  import "DPI-C" function int dpi_add(input int a, input int b = 2, input int c = 3);
  int r;
  initial begin
    r  = dpi_add(1,,4);
    r += dpi_add(1,2,);
  end
endmodule
