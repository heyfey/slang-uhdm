// § colSpanWalkStampsFile246
`define CF_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<sz) ARG.push_back(VAL); \
  while(ARG.size()>sz) void'(ARG.pop_front()); \

`define CF_FIELD(TYPE,ARG) \
  begin \
    int sz = 3; \
    `CF_``TYPE``_RESIZE(ARG,"") \
  end \

package p;
  class c;
    string abstractions[$];
    function void auto_f();
      `CF_FIELD(QUEUE, abstractions)
    endfunction
  endclass
endpackage
module top;
endmodule
