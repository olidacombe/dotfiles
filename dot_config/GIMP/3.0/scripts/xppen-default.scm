; GIMP 3.0 Startup Script - Auto Create 1920x1200 Black Image
; Place this file in your GIMP scripts folder:
; - Linux: ~/.config/GIMP/3.0/scripts/
; - Windows: %APPDATA%\GIMP\3.0\scripts\
; - macOS: ~/Library/Application Support/GIMP/3.0/scripts/
; Name it something like: auto-create-black-image.scm

(define (blackboard)
  (let* (
         ; Define image dimensions
         (width 1920)
         (height 1200)
         
         ; Create new RGB image
         (img (car (gimp-image-new width height 0))) ; 0 for RGB
         
         ; Create new layer - GIMP 3.0 syntax
         (layer (car (gimp-layer-new img
                                      "Background"  ; layer name
                                      width
                                      height
                                      0            ; RGB with alpha
                                      100          ; opacity
                                      0)))         ; normal mode
         
         ; Create display for the image
         ;; (display (car (gimp-display-new img)))
        )
    
    ; Add layer to image
    (gimp-image-insert-layer img layer 0 0)
    
    ; Set foreground color to black
    (gimp-context-set-foreground '(0 0 0))
    
    ; Fill layer with black (0 = foreground)
    (gimp-drawable-fill layer 0)

    (gimp-display-new img)
    
    ; Update display
    (gimp-displays-flush)
    
    ; Return success
    #t
  )
)

; Register the function to run at startup
(script-fu-register
  "blackboard"
  "Auto Blackboard Image"
  "Automatically creates a 1920x1200 black image"
  "Oli Dacombe"
  "Oli Dacombe"
  "2025"
  ""
)

; Call the function immediately when script loads
; FIXME this just hangs
;; (blackboard)
