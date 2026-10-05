// § colSpanWalkStampsFile246
`define CF_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<szcf) ARG.push_back(VAL); \
  while(ARG.size()>szcf) void'(ARG.pop_front()); \

`define CF_PASTE(TYPE,ARG) \
  begin \
    int szcf = 2; \
    `CF_``TYPE``_RESIZE(ARG,0) \
  end \

package p;
  class inner; int q[$]; endclass
  class c;
    inner in;
    int qa[$];
    function void f();
      `CF_PASTE(QUEUE, in.q)
      `CF_PASTE(QUEUE, this.qa)
    endfunction
  endclass
endpackage
module top;
endmodule
