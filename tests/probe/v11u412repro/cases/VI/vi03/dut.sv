// § elabVarSysCallInit412
class C;
  int r = $urandom;
endclass
module top(output logic [31:0] o);
  function automatic int f();
    static int k = $urandom;
    int j = $random();
    return k + j;
  endfunction
  assign o = f();
endmodule
