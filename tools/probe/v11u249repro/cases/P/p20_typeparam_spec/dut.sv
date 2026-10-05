// § clsPropWholeArrTd249 (control: the law does not fire)
typedef int f_t[4];
class c #(type T = int);
  T m;
endclass
module top; c #(f_t) h; endmodule
