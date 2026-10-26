// § unitNameBindNotInClass431v (a module class's property range reading the shadowing localparam)
localparam W = 2;
module top(output int y);
localparam W = 4;
class C;
  bit [W-1:0] v;
  function int g(); return W; endfunction
endclass
initial begin C o = new; y = o.g(); end
endmodule
