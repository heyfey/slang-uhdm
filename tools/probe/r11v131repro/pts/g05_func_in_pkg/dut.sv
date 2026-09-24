// § pkgParamTsRefColons131
package pk;
  parameter int W = 4;
  function automatic logic [W-1:0] f();
    localparam logic [W-1:0] Z = '1;
    return Z;
  endfunction
endpackage
module top (output logic [3:0] o);
  assign o = pk::f();
endmodule
