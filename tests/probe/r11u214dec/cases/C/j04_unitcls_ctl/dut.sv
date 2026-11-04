// § classScopeTdPkgListingParent214 — control: a class-scope typedef in a $unit class (no package listing holds it)
class Box #(type Q = int); int b; endclass
class solo;
  typedef Box #(solo) sid;
endclass
module top;
  solo s;
endmodule
