`include "cycle.sv"
`include "pwm.sv"

module top #(
  parameter PWM_INTERVAL = 1200
)(
  input logic clk,
  output logic RGB_R,
  output logic RGB_G,
  output logic RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_r;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_g;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_b;
    logic pwm_out_r;
    logic pwm_out_g;
    logic pwm_out_b;

    cycle #(
        .INC_DEC_INTERVAL (6000),
        .INC_DEC_MAX      (300),
        .PWM_INTERVAL     (PWM_INTERVAL),
        .START_STATE      (3)
    ) u1r (
        .clk            (clk), 
        .pwm_value      (pwm_value_r)
    );

    cycle #(
        .INC_DEC_INTERVAL (6000),
        .INC_DEC_MAX      (300),
        .PWM_INTERVAL     (PWM_INTERVAL),
        .START_STATE      (0)
    ) u1g (
        .clk            (clk), 
        .pwm_value      (pwm_value_g)
    );

    cycle #(
        .INC_DEC_INTERVAL (6000),
        .INC_DEC_MAX      (300),
        .PWM_INTERVAL     (PWM_INTERVAL),
        .START_STATE      (4)
    ) u1b (
        .clk            (clk), 
        .pwm_value      (pwm_value_b)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value_r), 
        .pwm_out        (pwm_out_r)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk            (clk), 
        .pwm_value      (pwm_value_g), 
        .pwm_out        (pwm_out_g)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u4 (
        .clk            (clk), 
        .pwm_value      (pwm_value_b), 
        .pwm_out        (pwm_out_b)
    );

    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;

endmodule
