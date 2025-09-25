; GIMP 3.0 Startup Script - Auto Create 1920x1200 Black Image
; Place this file in your GIMP scripts folder:
; - Linux: ~/.config/GIMP/3.0/scripts/
; - Windows: %APPDATA%\GIMP\3.0\scripts\
; - macOS: ~/Library/Application Support/GIMP/3.0/scripts/
; Name it something like: auto-create-black-image.scm

; TODO
; Set Palette
; Set Foreground to non-black
; Zoom-to-fit

(define (blackboard)
  (let* (
         ; Define image dimensions
         (width 1920)
         (height 1200)
         
         ; Create new RGB image
         (img (car (gimp-image-new width height 0))) ; 0 for RGB
         
         ; Create new layer - GIMP 3.0 syntax
         (bglayer (car (gimp-layer-new img
                                      "Background"  ; layer name
                                      width
                                      height
                                      0            ; RGB with alpha
                                      100          ; opacity
                                      0)))         ; normal mode

         ; Create new layer - GIMP 3.0 syntax
         (fglayer (car (gimp-layer-new img
                                      "Scratch"  ; layer name
                                      width
                                      height
                                      0            ; RGB with alpha
                                      100          ; opacity
                                      0)))         ; normal mode
         
         ; Create display for the image
         ;; (display (car (gimp-display-new img)))
        )
    
    ; Add layer to image
    (gimp-image-insert-layer img bglayer 0 0)
    
    ; Set background color to black
    (gimp-context-set-background '(0 0 0))
    
    ; Fill layer with black (0 = foreground)
    ;; (gimp-drawable-fill bglayer 1)

    (gimp-layer-add-alpha fglayer)

    ; (4 = transparent https://developer.gimp.org/api/3.0/libgimp/enum.FillType.html)
    (gimp-drawable-fill fglayer 4)

    ; Add layer to image
    (gimp-image-insert-layer img fglayer 0 0)

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
