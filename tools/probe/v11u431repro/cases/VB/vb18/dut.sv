// § unitNameBindNotInClass431v (a class inside the module reading the module localparam)
localparam CF = 2;
module top(output int y);
localparam CF = 1;
class C;
  function int f(); return CF; endfunction
endclass
initial begin C o = new; y = o.f(); end
endmodule
