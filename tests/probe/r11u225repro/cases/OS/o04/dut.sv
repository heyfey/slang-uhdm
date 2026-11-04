// § initHierAtRefToken225 — control: a plain integer override (no substitution)
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module top(output int o);
   logic [15:0] data;
   sub #(.Depth(16)) u (.a(data));
   assign o = int'(data);
endmodule : top
