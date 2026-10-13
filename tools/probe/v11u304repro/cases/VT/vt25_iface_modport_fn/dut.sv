// § tfBodyTypedefForcesBegin304
interface ifc;
  logic [3:0] d;
  function automatic logic [3:0] rd();
    typedef logic [3:0] n_t;
    return n_t'(d);
  endfunction
  modport mp (import rd);
endinterface
module top; ifc u(); endmodule
