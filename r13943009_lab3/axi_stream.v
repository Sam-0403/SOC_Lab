// module axi_stream
// #(  parameter pADDR_WIDTH = 12,
//     parameter pDATA_WIDTH = 32,
//     parameter Tape_Num    = 11,
//     parameter RAM_bit     = $clog2(Tape_Num)
// )
// (
//     input   wire                     ss_tvalid,
//     input   wire [(pDATA_WIDTH-1):0] ss_tdata,
//     input   wire                     ss_tlast,
//     output  wire                     ss_tready,

//     output  wire [3:0]               data_WE,
//     output  wire                     data_EN,
//     output  wire [(pDATA_WIDTH-1):0] data_Di,
//     output  wire [(pADDR_WIDTH-1):0] data_A,
//     input   wire [(pDATA_WIDTH-1):0] data_Do,

//     input   wire                     en,
//     output  wire                     shift,
//     output  wire                     wait_ram,

//     input   wire                     ap_start,
//     input   wire                     ap_done,
//     input   wire     [(RAM_bit-1):0] FIR_addr,
//     output  wire [(pDATA_WIDTH-1):0] FIR_data,

//     input   wire                     axis_clk,
//     input   wire                     axis_rst_n
// );

//     reg [3:0]               data_WE_reg;
//     reg                     data_EN_reg;
//     reg [(pADDR_WIDTH-1):0] data_A_reg;
//     reg [(pDATA_WIDTH-1):0] data_Di_reg;

//     reg [(RAM_bit-1):0] write_ptr;
//     reg [(RAM_bit-1):0] write_nptr;

//     reg shift_reg;
//     reg wait_ram_reg;

//     reg           [1:0] state_r;
//     reg           [1:0] state_w;
//     localparam IDLE      = 2'b00;
//     localparam INIT      = 2'b01;
//     localparam WAIT      = 2'b10;

//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if(~axis_rst_n) begin
//             state_r <= IDLE;
//             write_ptr <= 0;
//         end
//         else begin
//             state_r <= state_w;
//             case(state_r)
//                 IDLE: begin
//                     write_ptr <= write_nptr;
//                 end
//                 INIT:begin
//                     write_ptr <= write_nptr;
//                 end
//                 WAIT:begin
//                     if (w_hs) begin
//                         write_ptr <= write_nptr;
//                     end
//                     else begin
//                         write_ptr <= write_ptr;
//                     end
//                 end
//             endcase
//         end
//     end


//     always@* begin
//         case(state_r)
//             IDLE: begin
//                 wait_ram_reg = 0;
//                 data_Di_reg = 0;
//                 data_A_reg  = 0;
//             end
//             INIT: begin
//                 data_Di_reg = 0;
//                 data_A_reg  = {6'b0,write_ptr,2'b00};
//                 wait_ram_reg = 0;
//             end
//             WAIT: begin
//                 wait_ram_reg = 1;
//                 if (w_hs) begin
//                     data_Di_reg = ss_tdata;
//                     data_A_reg  = {6'b0,write_ptr,2'b00};
//                 end
//                 else begin
//                     data_Di_reg = 0;
//                     data_A_reg  = {6'b0,FIR_addr,2'b00};
//                 end
//             end
//             default: begin
//                 wait_ram_reg = 0;
//                 data_Di_reg = 0;
//                 data_A_reg  = 0;
//             end
//         endcase
//     end

//     always@* begin
//         case(state_r)
//             IDLE: begin
//                 data_EN_reg = 0;
//                 data_WE_reg = 4'b0000;
//             end
//             INIT: begin
//                 data_EN_reg = 1;
//                 data_WE_reg = 4'b1111;
//             end
//             WAIT: begin
//                 data_EN_reg = 1;
//                 if (w_hs) begin
//                     data_WE_reg  = {4{w_hs}};
//                 end
//                 else begin
//                     data_WE_reg = 4'b0000;
//                 end
//             end
//             default: begin
//                 data_EN_reg = 0;
//                 data_WE_reg = 4'b0000;
//             end
//         endcase
//     end

//     always@* begin
//         case(state_r)
//             IDLE: begin
//                 if (ap_start) begin
//                     state_w = INIT;
//                 end
//                 else begin
//                     state_w = IDLE;
//                 end
//                 write_nptr = 0;
//             end
//             INIT: begin
//                 if (write_ptr == (Tape_Num-1)) begin
//                     state_w = WAIT;
//                     write_nptr = 0;
//                 end
//                 else begin
//                     state_w = INIT;
//                     write_nptr = write_ptr + 1;
//                 end
//             end
//             WAIT: begin
//                 if (w_hs) begin
//                     if (write_ptr == (Tape_Num-1)) begin
//                         write_nptr = 0;
//                     end
//                     else begin
//                         write_nptr = write_ptr + 1;
//                     end
//                     state_w = WAIT;
//                 end
//                 else if (ap_done) begin
//                     state_w = IDLE;
//                     write_nptr = 0;
//                 end
//                 else begin
//                     state_w = WAIT;
//                     write_nptr = write_ptr;
//                 end
//             end
//             default: begin
//                 state_w = IDLE;
//                 write_nptr = 0;
//             end
//         endcase
//     end

//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if(~axis_rst_n) begin
//             shift_reg <= 0;
//         end
//         else if (w_hs) begin
//             shift_reg <= 1;
//         end
//         else begin
//             shift_reg <= 0;
//         end
//     end

//     assign data_EN = data_EN_reg;
//     assign data_WE = data_WE_reg;
//     assign data_Di = data_Di_reg;
//     assign data_A  = data_A_reg;
//     assign ss_tready = (ss_tvalid & en);
//     assign w_hs = ss_tready & ss_tvalid;

//     assign shift = shift_reg;
//     assign wait_ram = wait_ram_reg;

//     assign FIR_data  = data_Do;

// endmodule

`timescale 1ns / 1ps

module axi_stream
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11,
    parameter RAM_bit     = $clog2(Tape_Num)
)
(
    input   wire                     ss_tvalid,
    input   wire [(pDATA_WIDTH-1):0] ss_tdata,
    input   wire                     ss_tlast,
    output  wire                     ss_tready,

    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     en,
    output  wire                     shift,
    output  wire                     wait_ram,

    input   wire                     ap_start,
    input   wire                     ap_done,
    input   wire     [(RAM_bit-1):0] FIR_addr,
    output  wire [(pDATA_WIDTH-1):0] FIR_data,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);

    reg [3:0]               data_WE_reg;
    reg                     data_EN_reg;
    reg [(pADDR_WIDTH-1):0] data_A_reg;
    reg [(pDATA_WIDTH-1):0] data_Di_reg;

    reg [(RAM_bit-1):0] write_ptr;
    reg [(RAM_bit-1):0] write_nptr;

    reg shift_reg;
    reg wait_ram_reg;

    reg           [1:0] state_r;
    reg           [1:0] state_w;
    localparam IDLE      = 2'b00;
    localparam INIT      = 2'b01;
    localparam WAIT      = 2'b10;

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(~axis_rst_n) begin
            state_r <= IDLE;
            write_ptr <= 0;
        end
        else begin
            state_r <= state_w;
            case(state_r)
                IDLE: begin
                    write_ptr <= write_nptr;
                end
                INIT:begin
                    write_ptr <= write_nptr;
                end
                WAIT:begin
                    if (w_hs) begin
                        write_ptr <= write_nptr;
                    end
                    else begin
                        write_ptr <= write_ptr;
                    end
                end
            endcase
        end
    end


    always@* begin
        case(state_r)
            IDLE: begin
                wait_ram_reg = 0;
                data_Di_reg = 0;
                data_A_reg  = 0;
            end
            INIT: begin
                data_Di_reg = 0;
                data_A_reg  = {6'b0,write_ptr,2'b00};
                wait_ram_reg = 0;
            end
            WAIT: begin
                wait_ram_reg = 1;
                if (w_hs) begin
                    data_Di_reg = ss_tdata;
                    data_A_reg  = {6'b0,write_ptr,2'b00};
                end
                else begin
                    data_Di_reg = 0;
                    data_A_reg  = {6'b0,FIR_addr,2'b00};
                end
            end
            default: begin
                wait_ram_reg = 0;
                data_Di_reg = 0;
                data_A_reg  = 0;
            end
        endcase
    end

    always@* begin
        case(state_r)
            IDLE: begin
                data_EN_reg = 0;
                data_WE_reg = 4'b0000;
            end
            INIT: begin
                data_EN_reg = 1;
                data_WE_reg = 4'b1111;
            end
            WAIT: begin
                data_EN_reg = 1;
                if (w_hs) begin
                    data_WE_reg  = {4{w_hs}};
                end
                else begin
                    data_WE_reg = 4'b0000;
                end
            end
            default: begin
                data_EN_reg = 0;
                data_WE_reg = 4'b0000;
            end
        endcase
    end

    always@* begin
        case(state_r)
            IDLE: begin
                if (ap_start) begin
                    state_w = INIT;
                end
                else begin
                    state_w = IDLE;
                end
                write_nptr = 0;
            end
            INIT: begin
                if (write_ptr == (Tape_Num-1)) begin
                    state_w = WAIT;
                    write_nptr = 0;
                end
                else begin
                    state_w = INIT;
                    write_nptr = write_ptr + 1;
                end
            end
            WAIT: begin
                if (w_hs) begin
                    if (write_ptr == (Tape_Num-1)) begin
                        write_nptr = 0;
                    end
                    else begin
                        write_nptr = write_ptr + 1;
                    end
                    state_w = WAIT;
                end
                else if (ap_done) begin
                    state_w = IDLE;
                    write_nptr = 0;
                end
                else begin
                    state_w = WAIT;
                    write_nptr = write_ptr;
                end
            end
            default: begin
                state_w = IDLE;
                write_nptr = 0;
            end
        endcase
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(~axis_rst_n) begin
            shift_reg <= 0;
        end
        else if (w_hs) begin
            shift_reg <= 1;
        end
        else begin
            shift_reg <= 0;
        end
    end

    assign data_EN = data_EN_reg;
    assign data_WE = data_WE_reg;
    assign data_Di = data_Di_reg;
    assign data_A  = data_A_reg;
    assign ss_tready = (ss_tvalid & en);
    assign w_hs = ss_tready & ss_tvalid;

    assign shift = shift_reg;
    assign wait_ram = wait_ram_reg;

    assign FIR_data  = data_Do;

endmodule
