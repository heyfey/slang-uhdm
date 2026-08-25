// r10uvm136 arm B include — typedefs whose FILE LINES are LARGER than the line
// of the class that uses them, but whose include position puts them in scope
// first (the head's own uvm_reg_model.svh:412 shape).
typedef struct packed { bit [9:0] lowEnd; bit [9:0] highEnd; } inc_range_ps;
typedef struct { int cnt; string tag; } inc_loose_us;
typedef enum int { T_ONE = 1, T_FIVE = 5 } inc_tone_e;
