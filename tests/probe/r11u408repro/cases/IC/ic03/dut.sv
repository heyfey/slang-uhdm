// § ifaceClassNotListed408
class Base; endclass
interface class Bar; endclass
class Foo extends Base implements Bar;
  int x;
endclass
module test;
  Foo f;
  initial f = new;
endmodule
