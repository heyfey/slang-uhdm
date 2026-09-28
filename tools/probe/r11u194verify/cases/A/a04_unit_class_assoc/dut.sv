// § assocBracketPkgOnly186 § assocPromotedBoundAtBracket183: a $unit class with typedef-, int- and string-keyed properties and an out-of-body method's local, beside a $unit function
typedef logic [3:0] uk_t;
class uc;
  int pt[uk_t];
  int ps[string];
  extern function void run();
endclass
function void uc::run();
  int loc[uk_t];
  loc[4'd2] = 1;
endfunction
function automatic int uf();
  int m[uk_t];
  return m.num();
endfunction
module top; endmodule
