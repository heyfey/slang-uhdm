// vrgg17 v4 — the HOME axis: module scope / gen-if / gen-case / nested gen /
// a PROGRAM body, and 1..3 instances of the containing module.
interface sif; logic [31:0] value; endinterface
module sink (input logic [3:0] d); endmodule
module mid;
  sif arr[20]();
  for (genvar i = 0; i < 2; i++) begin : go
    if (i == 0) begin : gi
      sink u_h1 (.d(arr[6+7*i].value[0+:4]));   // gen-IF home
    end
    case (i)
      0: begin : gc  sink u_h2 (.d(arr[1+2*i].value[0+:4])); end
      default: begin : gd sink u_h3 (.d(arr[4+2*i].value[0+:4])); end
    endcase
    for (genvar j = 0; j < 3; j++) begin : gn
      sink u_h4 (.d(arr[i+j].value[0+:4]));     // nested gen, BOTH genvars
    end
  end
  sink u_h5 (.d(arr[3].value[0+:4]));           // MODULE SCOPE, literal
endmodule
program prg;
  initial begin end
endprogram
module top;
  mid m1(); mid m2(); mid m3();                 // THREE instances
  prg p1();
endmodule
