// § ppOutputFile166 § aggFoldReanchorFile177v
module sub #(parameter p::cfg_t C = '{A: 1, B: 1}) (output logic [C.A-1:0] o);
  assign o = '0;
endmodule
module top (output logic [4:0] o);
  sub #(.C(p::D)) u (.o(o));
endmodule
