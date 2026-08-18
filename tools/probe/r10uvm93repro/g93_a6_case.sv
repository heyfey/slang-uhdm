// r10uvm93 arm A6 -- case sensitivity, near-miss spellings and the
// non_integer_type family.  A keyword table that matched loosely would fold
// INT/Int/int_t/tint the same way `int` folds; golden must not.
package zq93_pk6;
  typedef bit [23:0] INT;      // an IDENTIFIER that only LOOKS like a keyword
  typedef bit [21:0] Int;
  typedef bit [19:0] int_t;
  typedef bit [17:0] tint;
  typedef bit [15:0] logic_t;
  typedef bit [13:0] BIT;
endpackage
module zq93_case;
  import zq93_pk6::*;
  byte cinder[];
  bit [63:0] flume;
  initial begin
    { << INT     { cinder }} = flume;
    { << Int     { cinder }} = flume;
    { << int_t   { cinder }} = flume;
    { << tint    { cinder }} = flume;
    { << logic_t { cinder }} = flume;
    { << BIT     { cinder }} = flume;
    { << int     { cinder }} = flume;
    { << real    { cinder }} = flume;
    { << shortreal { cinder }} = flume;
  end
endmodule
