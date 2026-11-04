// § newArrayArgPathElemsStripped200 § newArrayPathStripTrailOnly201v
class L3; int n; endclass
class L2; L3 l3; endclass
class L1; L2 l2; endclass
module a02;
  L1 l1;
  int d[];
  initial begin
    d = new[l1.l2.l3.n];
    d = new[l1.l2.l3.n * 2](d);
  end
endmodule
