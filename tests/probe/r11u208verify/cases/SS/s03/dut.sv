// § tfSigningSpanFollowsCompilePath200
`define TY(x) x
`define SGN signed
module s03(input logic [7:0] a, output logic [63:0] y);
  function automatic `TY(longint unsigned) f(input `TY(int `SGN) i);
    return i;
  endfunction
  task automatic t;
    input integer signed ni;
    input time unsigned nt;
    output shortint unsigned no;
    no = ni + nt;
  endtask
  function automatic byte
      unsigned
      h(input bit
        signed [2:0] q);
    return q;
  endfunction
  assign y = f(a) + h(a[2:0]);
endmodule
