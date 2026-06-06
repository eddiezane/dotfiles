{ ... }:

{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      allow_images = true;
      width = 750;
      height = 400;
      always_parse_args = true;
      show_all = false;
      print_command = true;
      insensitive = true;
      prompt = "";
    };
    style = ''
      /* Macchiato Blue */
      @define-color accent #8aadf4;
      @define-color txt #cad3f5;
      @define-color bg #24273a;
      @define-color bg2 #494d64;

      * {
        font-family: 'SauceCodePro Nerd Font', monospace;
        font-size: 14px;
      }

      window {
        margin: 0px;
        padding: 10px;
        border: 3px solid @accent;
        border-radius: 7px;
        background-color: @bg;
      }

      #inner-box, #outer-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: @bg;
      }

      #scroll {
        margin: 0px;
        padding: 10px;
        border: none;
      }

      #input {
        margin: 5px;
        padding: 10px;
        border: none;
        color: @accent;
        background-color: @bg2;
      }

      #text {
        margin: 5px;
        padding: 10px;
        border: none;
        color: @txt;
      }

      #entry:selected {
        background-color: @accent;
      }

      #entry:selected #text {
        color: @bg;
      }
    '';
  };
}
