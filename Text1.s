;Convert Sonix tune to wave

;1000 Wave memory
;7700 Sonix memory (loaded as patterns then
;A000 Converter code


ConvertPatterns
	lda (sonix),y
	