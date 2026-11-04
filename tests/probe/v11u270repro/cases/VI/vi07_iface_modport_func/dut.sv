// § insideSetParamFoldKeepsPa270
interface ifc #(parameter int P = 3);
  int w;
  function automatic bit hit();
    return w inside {P, 7};
  endfunction
  modport m (input w, import hit);
endinterface
module top;
  ifc #(.P(4)) i();
  bit h;
  always_comb h = i.hit();
endmodule
