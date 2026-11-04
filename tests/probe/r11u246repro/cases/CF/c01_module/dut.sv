// § colSpanWalkStampsFile246
`define CF_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<szcf) ARG.push_back(VAL); \
  while(ARG.size()>szcf) void'(ARG.pop_front()); \

`define CF_PASTE(TYPE,ARG) \
  begin \
    int szcf = 2; \
    `CF_``TYPE``_RESIZE(ARG,"") \
  end \

module sub_cf;
  string qa[$];
  string qbb_long_cf[$];
  initial begin
    `CF_PASTE(QUEUE, qa)
    `CF_PASTE(QUEUE, qbb_long_cf)
  end
endmodule
module top;
  sub_cf i0();
endmodule
