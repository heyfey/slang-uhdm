// r10v205 arm I — DEPTH.  `walk205` recurses with budget 8 through
// `array_typespec` and `packed_array_typespec`.  Nothing on the corpus went
// deeper than one link, so depth >= 2 ships untested: an array of an array, a
// packed array of a typedef inside an unpacked array, and a typedef'd array
// element type (the R2 shape) in a wildcard-import clone body.
package p205a_i;
  typedef bit  [7:0]      bt205;
  typedef bit  [3:0][7:0] pt205;
  typedef bt205           row205_t [4];
  function automatic int fi205(input bt205 iio205[]);
    bt205  d2205 [][];            // dynamic array of dynamic array
    bt205  f2205 [2][3];          // fixed 2-D
    pt205  pk205 [];              // unpacked array of a PACKED-array typedef
    row205_t rr205 [];            // unpacked array of a typedef'd ARRAY
    bt205  q2205 [$][$];
    return iio205.size() + d2205.size() + pk205.size() + rr205.size()
         + q2205.size() + int'(f2205[0][0]);
  endfunction
endpackage

package p205b_i;
  import p205a_i::*;
  function automatic int gi205();
    bt205 z205[];
    return fi205(z205);
  endfunction
endpackage

module v205_i_nested;
  import p205b_i::*;
  int r205;
  initial r205 = gi205();
endmodule
