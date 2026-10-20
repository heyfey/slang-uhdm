// § tdKeptParentMemberNames418
import tp::tag_s;
module m (input tag_s ti, output o);
  typedef struct packed { logic x; tag_s t; } loc_s;
  loc_s l;
endmodule
