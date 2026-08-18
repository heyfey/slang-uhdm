// r10uvm99 arm a3: `inside` in CONSTRAINT blocks (class scope).
class beta99;
  rand int cval;
  rand int dval;
  rand bit [3:0] eval99;
  int lowb = 3;
  int highb = 8;
  constraint c_one { cval inside {[1:3]}; }
  constraint c_two { dval inside {2, [4:6], 9}; }
  constraint c_three { eval99 inside {[lowb:highb]}; }
  constraint c_four { !(cval inside {[10:20]}); }
  constraint c_five { cval dist { [1:3] := 1, 5 := 2 }; }
endclass
module gamma99;
  beta99 obj99;
  initial obj99 = new();
endmodule
