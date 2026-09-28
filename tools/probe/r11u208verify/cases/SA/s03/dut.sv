// § sysCtxRefArgBare201
interface ifc (input logic [3:0] a);
  logic [31:0] y;
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = $countones(f(a));
endinterface
module s03 (input logic [3:0] a, output logic [31:0] y1);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign yi = $countones(f(a));
  ifc i (a);
  assign y1 = i.y + yi;
  for (genvar k = 0; k < 2; k++) begin : g
    wire [31:0] z;
    assign z = $countones(f(a[k +: 2]));
  end
endmodule
