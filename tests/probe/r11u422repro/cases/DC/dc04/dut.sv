// § derivedClassFullNameOrder422
class B; endclass
class Z extends B; endclass
class A extends B; endclass
module top; A a; Z z; endmodule
