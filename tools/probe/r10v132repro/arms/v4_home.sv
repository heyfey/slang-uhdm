// macro DEFINED IN THE SAME FILE AS ITS USE (a different mechanism), plus
// receiver names of three different lengths and three instances.
`define V4_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<sz4132) ARG.push_back(VAL); \
  while(ARG.size()>sz4132) void'(ARG.pop_front()); \

`define V4_PASTE(TYPE,ARG) \
  begin \
    int sz4132 = 3; \
    `V4_``TYPE``_RESIZE(ARG,"") \
  end \

module sub_v4132;
  string q1[$];
  string qq_two_132[$];
  string a_very_long_receiver_name_132[$];
  initial begin
    `V4_PASTE(QUEUE, q1)
    `V4_PASTE(QUEUE, qq_two_132)
    `V4_PASTE(QUEUE, a_very_long_receiver_name_132)
  end
endmodule
module top_v4132;
  sub_v4132 i0_v132();
  sub_v4132 i1_v132();
  sub_v4132 i2_v132();
endmodule
