`define CF_QUEUE_RESIZE(ARG,VAL) \
  while(ARG.size()<szcf) ARG.push_back(VAL); \
  while(ARG.size()>szcf) void'(ARG.pop_front()); \

`define CF_PASTE(TYPE,ARG) \
  begin \
    int szcf = 2; \
    `CF_``TYPE``_RESIZE(ARG,"") \
  end \

