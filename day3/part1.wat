;; MEMORY MAP
;; 0 PTR_FOR_RET_VAL ugh
;; 4 OUTPUT_STR PTR 
;; 8 OUTPUT_STR LEN 
;; 12 OUTPUT_STRING
;; 28 PUZZLE_INPUT
;; ......\0

(module
  ;; (fd, *iovs, iovs_len, nwritten) 
  ;; -> Returns number of bytes written
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory 1)
  (export "memory" (memory 0))

  ;; puzzle input
  ;;(data (i32.const 28) "vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw\n\u{0000}")
  (data (i32.const 28) "gfWpjRRQffQGCHHJsGqjsj\nSclzJZZvmmnPbJtVSqqNBqVCBdSCsd\ntlbvZJDZtmtPcJmlPnhMFQWWpMRFTfLDRRTWRp\nHjMPgSWjVrjgbHRRSSMRgjRdpdbGdlcdCvQfcCdlwQJfdf\nLNDnhtNtLNFFZDtFnhzvdldDflvvDCdlJfldpJ\nZFLFZZmFtFtTNTSPRrVPWWMpRP\nqLBSBLRwmgzqCbzCffDlrfCV\nTFFFHNWFMFFMpHpGHMTHGNhrldWZCsdZsslZlZfrflDVss\nPTMcPGntTThHhTGctnMvSwjjvmmqLBmnjqqgCR\nnClJtMwwntqVVPJcgZqq\nmjpsDcrcSSFFPZqFBWWgVP\nvQcjsvhrvvrmhbmNHMNnlHbNMtCtNM\nbgvvhnTQtjrrrhsDDf\npLSMltLzLLSjFrSSjrSJHD\nzNWRLBdZPllPQtCvttgCqb\nDRlDrrFTNDNlgzsGTBfcnqhhcnJfcrCSqc\nMMmmdWtdLmvtldHjMmQfPBqSJWnfCCCqcWSSPJ\nvjHMjLmjpLtHptQLmHvwTRgNVVpTzZFZgZRlsVTN\nrzpMpDCGFCFFjRFsRPFRNFPv\nfWclbHCHtSmfvjnmfsvZ\nwTcTlSwwtQtWclBQBLGMLMCLVzVLwJGqLd\nMQSjLNjPPLLSBPjfQhSPHjDVCjDtVVpDHwbwVpbD\nRcmWzsRrzZrmTszWRqWlmRJscbtHwCbndCtcDVddDpdnVnbt\nJTsrGGTqmwTlWmTzJzWmhhPLLGgPFgBffSSPhFFM\nqMMRNZMDDNWLPqfzCgDcGncVDCgG\nwwBFhwhhBgmcVzhghG\ntbJbjjtJvwtdtwjpFtlbvtdTLNSMqNqMMgqNHPlZRTNggL\nqmjMHsZmZSbjbZMjSLFFFFwgsgvFswpwww\nhRJBhmnhhvFFwhcv\nllfWDWzrzBNTRfNBrWzzTmZbGTMjPqMmZPjVbSZGSP\nCRRPLwwcclcGVppQ\nSHFjDjjHDTfSDNTTHfSHjQVGrpmllQQWltVVVZGp\nHFlqzDTfqlzwbgPJLwCP\nWRCNLphpLppSCWVHNfLRzVnQMnBnMddPMQDFQgrhPQFM\njTjJqvqjvPVJFJFBJF\nqTsZbvGqqZlstsmZVljtwqwSHHNWczHSSRcWNSRHzzNfbW\nglgzDzHjSrVHcVgbrjmNsscNGmNWssGNNtst\nhHPQLHJpwdLpdHfQQtnZmNMwnZGZWwsFZM\nQpdhPJRTJfPphJfhCBlVqVvgvVDBbvVqDbHD\nVtHzjZpjVtHrprgGmjHsGHNdSJFQRcLJqCdQcSqJNpcq\nbBWfTPwhbfDlMnhffRwQJQNdqJcLFQLSdR\nbhBhvfMWTnlDnTBfPSmvmjsjmmGtzHtsHm\npcRPRPWrSDcJGZSStmwZZS\nVnLfCfTlfVzfnMMBCqVNZJdtjNtJjhJdGNNbwT\nBLvqCCMVsnRQsPQgDcZH\ncQbqqQhDGhlQfQlhQrqGsTNgLgCpRgLTPPPLNbpg\nwtHVddVFwSHznZwwznCpRBdjppNBNTTdCjRR\nZtWFwWtSmvVnwZDrCMGfQlDDJQmD\nPzPZGCZzrZrlhdjdCqfCsqQdRD\ncbvZLVVFvbbNSNFHSDnsDQdnfqNQDRngsR\nFJHSLSFSScJJbWHFmFVFSZmrrzBmhtBwmzBMPMPzPh\nnlpFcLBgcVcLbssGVBGGrlpGPhJJJJJqPBZPDNMQMJJhJQZZ\nSSTjHzfHwtZSPVQVQMRQ\nTzVHwWfTtzwdVzsbFnGgsbdcGrLc\nFppVBRVZDdLmrDGmmfrQ\nNtNMPNshJCzznLGJSrqRrRrr\ntRssthhPlCWhPzsWtzhzCbVVjwTpVwdZZTpwjbdBbwBc\nTTWblHWScvPCCHTWFzSrqqsNNSmdmqrrpz\nRLRwjjnjZNprzmmZcq\nQQgtQnccQDGjgLDRRcLthQhFBvCbMtMHTWlBFllBbFCMTW\nWnBVNvDnVsNvZWdrWDLVDMbsHpTjpHCSSClsbSCCMH\nGPFtmztzgPhRFtJTdbTwjppSCjpgSl\nhJcfPtQhdtWNVZqNnqNQ\nGLcqZPPsnqQcFsmBBrqRvrddNqrC\nMtHthJwLllwvjRvvtrvBRS\nVHMfDLbpfznszZQG\nWBSdPlQPRfBtGQPfBGPBJgzgjwsJzsszJwCrdwCT\nZpppVpMVpnVHMVVbZRJrCgwRzTJrwNJw\nMvhmnpLqLmhVmBlftRQBFSlR\nhhQlSJqhtCSnqZJnqShSlNDwRzpvdwRlMBMMdcjRjMpMRc\nfrrGmLmWbfFrsmFHmBzBvBcwdJbvpjzbMM\nmmgFrVGLWJLFGsgfhSVtVPqntqnnSStN\nSFJTJTSqswwFQbwf\ncDtcWPclrtPwVsfssQmN\nHDtwWCgWdggdzSGJMSzGMq\nJpqJtWRJMhCMJpMQCWtFrjgHdgdlgllwNjlQjldH\nfBzPZcZvnBmDnZvZBZDmPvglVVVdgHHSwrNRgVgwNPRH\nGbZnZccfvcsZmccsmnnZTRbCCMWFTWJqFCCMJFRT\nvrrFqrFTBTmLmNrLMqMTHddJbHpWnhdWdWbHhJGM\nwBzfwzcQSzWSSshpdWGp\ngwjPPPDQtzQlzQDPqTgLBRmRqZBvqFNR\nbWVptFFsbPcZsGLhsZGmLB\nqnWrnrHdMCDCNqfWmvRRZSSRLdRGZGRG\nnNqqNDfMrMWHDQNHzWfHNDnwzblpzFlbwtFbVVlwVcPJpP\nBHJhlHdJQggvddglJBBhglhQzZHPZpFFPDMzFDDRDFZZDFZD\nrSTfqnCffMfCVfCLNqbzbjWNDbbWDPFpPFbP\nnfnnrSfCTVSwrqSLCGfTGlgQhlvsGMJQJBhhssJhGc\ntBjjDjjqfDjLfJlrLgglvmrlmrcc\nTwNNTVhwwpgvGSNNSssS\nTbwhnvvChhbVRTPPRJBJQQfJttMQQJCQfW\nmWSvSQVgmWQsQvspQJlrlLnJLLpCClhhlp\nbFHRjZdNjjBZzFzhtnCllCcJLrCBll\nHFFNHbdZZLZjfPFjHVQmWDDVsvsmTqVqDf\nJJPllQQClqgBCgdHwHbpjVTwHd\ntmGZtjGjHZpVbfMT\nShGjNGWmDSNcNRtGmshDRzzCvzQJJRBLrvlrBPJv\ncTpqsTWqVVpsNLfvCDFlMFDVFL\nJnndJPddQgzHlvMJFDhLCG\nBjtntgdRnQgzjdBRQBlpNWrTTlNTSwNpWS\nqHmqLVLjmVqsDBLtmjmbtPwCTwwPzGWRgGwGwMwW\nZhcCNCSprRTWTwSnWW\nhflhZvvQhppZfcNpvrhpQHjVjLmbVmmVHVCFDvqVFb\nnnNrwDnZrspwDNnZsNSDsNbCmpjvMTPQjLMmPmmQPGBTQP\nFdVtRdRfctBQPmTtTLQB\nqhzWVWJqVHwbhlLSsS\nhtWmhDhFztnztDhtBmBtghPRSrpfjVwPdfPwpwnRSVrr\ncbCHvgJGcTqbqcbqqqcqsMsRVrSCwffdRPPpVpwCRSwfjj\nGlgGQqTqbgQzttmBNNFz\nNWQNQgdTgjQNddTZfrCQWRDnnnbqnLqnRcjJlqqvDj\nFtSSmSmJhpllcclDvpln\nJBVVSsSFBVBttShFGSPQfCGNdrMfZZTQTZNNdC\nHgHthMhphcbfbMMfHhsGGDCRRVlcVSScsCRz\nnWvPFqLqPNdjnNLnjdJnPdWjGlssDPSsllVCRzlTCTGlSDzS\nRvddJRJQHwQwpZZb\ngdZwgpjZZQtHTdrWrwdpWRnlhNBRlLbFthNhflhBnL\nCVzDCPGMVqVmGsGGbJCmCDvMcRcqnBFFFnRBBNRBBNqhnFfF\nDsmSGsGPzvMGJvdbgTSTbjbSSdgH\njBGmbNBQGdBNNDJNQRLLVDsHtDRzHHZZcH\nwCWPFWPCrPhPrplvprhwpCHHtszttqZslRVHLtzVlJZL\nvprMMvMnJCwnnPShNGSTfGSfNmmgdNff\nbPtLbvVWWztbLSVVnbszpzQsrcDDBdpRcDrs\nllZmgCZqgCFgmdRdJcscBdJsmQ\nFZlgfqCFfgZHlqCMCglwCFGWntLLSMRSPGPVttWRtVGL\nvtnDsDtrnrSvrMVmbrrJgPCmBm\nFpQHzFclLVzWHhwHLQLlHLzPmMBQCJTdTmCTmBTJTTmgQg\npllcVWqlffZqZtZD\nTSSZWpsQmZWcTZSvsTTTppNPzrBPrNBrzQNVFrBBNPqP\nCgjmCbtGgftMmLtLmffzBzJJJNVVMNzNBqJrFN\ngjgjLgtLwgbGjHdhhGdvmlnllnpWnplZvcvwTl\nhtLrRFRtbbhlGSLRtbJBJsjBmgMMgJgtmBzz\npZQWddQQfpZZffcDQZwddQwDMqDDsPgGJJzzjqzgJMBJgmms\nQdcQTdwpGNwfrCRlRVlNLSbb\nwrdvpVBVpMGPPjWjGZJJZT\ntChCSlNfCCHtvHHWPHPZ\nRbRRNvmcqcblfMwwdVBQQqqdpL\nqcctqRcqmcHWzHBdDMZhfwthBnwt\nJFsSNMSgNSNJJMGJBBdjhFDfhwhBrwnZ\nTbgbsSgJMTJllblLCSPlsTCVQmRVVWpQzzqpqzVzHLQzcc\nCVcWbjjSSCSSnpjWpCpprhHZlHtHGzHrZrHGclrl\ngqZqdddLgmgNqvTGGHvvmrrGHT\nFFDgZfZNLMgNfdDqDRnsnjBpbSbnMBBWpQpB\nqwpQFwRnqFFfSBSfFt\nLJJLGLWWtZlbgWHgGshhSdSVzmhHmfVzzC\nlrbrbrNNJgDMLLbblGctvvvDqPcqctTTTcqP\nvnblvbfHvlcHMlHlZbSPLTPLwCMBRRPRRFFR\ntszzBqtzDsWVPRSmzLVmVL\ntsNsDDNgGsqBrgBpgdHQbfhflcHdpZvdbh\ncCpLtpGGLsgsppcpmGGHMtjfHRVhvvVVFRfhjV\nNWnnnNNndQnQZdCdzzRVMHzvhhHWWWjj\nCPJJrnSZpGDJLGTL\ncnJzpcnmnQVFbzTlvTHBlb\ntWCDPjfsDGfZhddhjjdTvFTgFgvbnFHvdHqT\nhjfCjwDDGjPthsfhsnGNrJcQcRmJMLVJrJNMLw\nCPPRrSlRccPcwTHwfdwTHdfl\nmLQLLjhQhhQLZvpzssHDhdTswzzTJD\ngmjbBvQLWmgbQZBCSRnnnSMVCBHnBS\nsWrBJbsVqschzhQzHh\ngtFmztnSlSfdlmnZSdSwcwGRTjcTcwwTcHccRg\nFzFDzMZCdDZtCSrJVBMqWVrqNBqN\nTvWlhhfhZJVgtSSl\nddBdGGdFmmBbdzqqPDDGGmdDZSgttHtZppSgzZHSgMhtMgtz\nPGqdrbbbdPnrcjjhTRWLLc\ntrrmJWcrVwVbcPScdcBdGPHH\nJTQnfjlJTpQFfMLlNJHHGDPdGsSdDjHGDPPH\nffFfnCTTCfTlplTMvNVzqWvwVzrrhwmWhJbW\nhVtDtgcghzJpmmhlwp\nsrsnrqqsPqsBPvnqRBRMPbnwlplpmCStJwmzJPtJzJfwSw\nbbrqjBbvGsjGGBWqMVFFVDNVNjZjgtgFgZ\nmnmhBDHhwWCHsTgRsH\ndcSlFvccMFMMFFggNsTzzvvzWnVW\nllQdllZScFplJPpdcZSqBqjhmtnrwrDGnQGhrq\nZffVNgfTdmPVltsnnGwgQDnB\nrMCFLMHpzCMFzHpzbrcHFLzBwsDsDDnlDBJrDDBBSJSnBn\nMLMjMzqpCzvwqTmwZdvq\nDDNlWPRqgPRPsRFjJQZbchJZbgQJ\nzzrLLznpLbHnjcBHvVvHvJcZ\nndmrTzbMMTfzrTfnTLrzdpmsPPPqlqGDNNsPCRDRqRsD\nzzdqTNfTfdfhgQhgqMFSjRDtDRWHqtWlwtqDRS\nssBCrcmpVGZvVRDdSDRwtmWdDb\nrvGPCZLCVCPVBZFdnfThgNgLJNhf\nbslcrssQwDPbQrrcsbsnQrjMLthPMMRhLRhLRgzmgPhRgM\nDffvDfHGfNFdpfTdMtghLBThzVmBhBtM\nSNvJNJdflDDbcDWJ\nHFlHNpWsTlGWbFsGFTGHFLLNzPPhLVPMzVzMNPhhzP\njSvZtmrqqpcrCpPVzw\ndddQvqDgDmjdSQQdqZjStpffWGgBRWTGfGsRlWBlHF\nTHnTbNrdBnLTHHnTnBrWRTndsccZsLZcDqmLDPcDlQDsmmsZ\nptwzzhpvGSVdqQlmszqmqPqc\nwGVjSddCBggCHFWN\nLFFbdbhhhvwvfTNdRhhRRvMbHDGjcfcGfDjtDHHcHqGjDqqj\nWlQnVpWSSWWsPsgDqDzHDLHjJcttGP\nrrWsZrgVnWrWSlmSlmSBFFbvTThhBFvvZLBhRw\nBgBdcjThvjFcTggrqvVfzlnnPlrqLt\nJpwJGPsQwpwSssHpPLlzlnNlzLLNNLVtsN\nJPMmWGmWPmHbHpJbWGJmDmwbBTRZMBBdZCRTRjFjhCZCCBTT\nBjbcLFRfBRhnbGjCVVvPllpcPtcDmdlPpvPP\nWrMQqCNgsqWWsTNCMZMWWsWPvJDJDddvlpDtZDpDDDDwvP\nqNMzzSzSQsGLbFCSCnVR\ntTRpHJQpQBZcddhhMhvhJN\nzswljflgMFbwPqmNmSdvShLNfLhm\nqFbsMCVgsqMwRWHCWDDBDWpt\nVSTCCWsJvGpHHCNC\nGrqzZrrZjDljcDDlfjMqgRPfPvQPpBHNvHvBpvNQ\nrljncDcznjMqhlhZDnltrzhTsGWtbVLFTTWGsbdWJdFTmL\nmJPDSJJPZPJNrprSNrDmpZGrhFFhBqjGbGGVbFjhhfqBjBRV\ncgnTQHdMQdTHdhqfggBhVqVfVS\nnQdLLddssSJrmsNvZrPz\njfjffQzZQQMzZZfZZQFgjDWBCRlCBdTTBGGGRpBCgdhdBG\nLrstWtNsbHLsprRBdlGpCwlh\nHLnntbnscqLvvPNNfMWSSmDMDPjzjDzS\nvhcGwWVvglltcfBn\nBBSLrzSJLzJNJrLfPfPRsmDRmflD\njMjFZJNMqzrzZzFNFjNQqJzbCpBBvWdpvTCWhpVwdvHVCGbG\nHlrnFmRmtRBQPVBTQHHQ\npsSLJsLpTTdPdLTv\nfCGgTgfSSCtRtFFzql\npfTpStppcDlWfbpDdzQRsQGJhfffQgJHzN\nZFZFZmBFwVwBVmLmLsRLRhHNzRLRNNzJ\nFnnjwVPmnqqqjBjrTdblldCTpcPJtbTD\nbdZHdWlrjslMMwGG\nrDDTRBTqSqmJLBJRBTSJpmMsMMjhwvfMhjjfVGsLshhC\nBqQFRPFRQBJgzrcZNHFdZt\nwrDdLlDdPWZPTTrwlZpSsPsHVHsSCHnbzMHM\nJtNFttNCjFvpppnMpJgSVS\nNFFqFcCQCvfrZmGdZdmqrW\nGMNNfJnNddJFJWsv\nHSDwCmmghLmwmmHDpsvdFpMWpppptSbp\nzCzBCgzhwmhzLrPnVrMqZBNfGf\nDrHGtbltbCjjjffPrgsmzmcqsgDczdsmgJ\nVZLwQLZLLVwLBQZnLVphhLQQqsTNmzJdcNTzzmJNqlNBsszz\nwZLhVMplpQVRRlpVGPfjCjMGCrbHGWWb\nBHpFrHHbBNTWWTWNhCPwPLNPjCdjLV\nzJRRzJvZlcZsSMJdzSDjDtfDCtDtjDjjjj\ndcJcszQJJGRJzRllMpGHpFTWmrTmBTbWWB\nqnWWqhDhnjmjCMBlNRrfVfRNCB\nvvBLBtGHJTHBddrNVJrVSVdr\nBZLTHbgvHvTFBgTFFvhmWmmZDPmmZDsnqncs\nWBvmjDbSzTMmHHdpNHNF\nttlflZRfGtfWVRltGtflCdHnJrNJHNHnJddNMNCnpF\nVVwssWQQfRGZcszBQzDbjSBvSBDP\nlSlQqQVqWWVWfqQWVJSTscdmPPwwTTmjjfpjPp\nFCbzHbvHvtgrtFCvbvbbwdTwmsrwnTTpmdswmwcc\nDtZbHdghztlLMQlWWhVQ\npqzzFSmdFqbQvlpdDGGrGBWPPBVNQnVttZ\ncgcjwfBMhHCjjLMCrtcnPcsnsPGVnrVs\nJgCChjjjBHhRRLLjjhplzvzpSFJvzzlDbSqm\nmZzVQZMhmrffwfQhWhzmrmpBtRcdbnbcdcMpBbDbncdD\njsLTSlTWRBSDpnDn\nGLTsGWGFsfmJGZVJZm\nBGWshBGnsFWSLWBLlSSLWRJHnrVPrPcNHCNHctnPPJ\nQmvQCqqMTZqvgmvTjpZCMgMtrVctPptHtrNVrptbJJbrRP\nCzjCZfCwDzShDWdF\nHmQlQHmJnpmptmzt\nMTqMjMPvTvVvhpdztZnSwzwZqS\nCcbLLPTMtCCsjHNHQFLRRFlRNN\nGDFwLLLLSrbdPlFBMFsslFHmZH\nTnJCgthHpVTfZMQZQmzWnZ\nhjvtjtghtqJvVjhTgNhJTvdvdDDRbbccrwPdcGwrHS\nMQQMBPzMGQBPBbDQPMhpnRwsGnRhNrFFpRnF\nvmgHcmCTTlvvvZvTmqcTfmCRdddFnwdRdnVwFpVfpRnwNw\ngvmqJTcHclCQJNzjMLWbLj\nDbqqDDbQFqfNtZSLSq\nRrdjPdmrpWBdmWRdccfLtNttSDMZBfftLMLf\ndCcgmgRrWcgcppjCVVVVFHFnDnbJnb\nfZMFfrtVdZSDVwTgjRMLhwTCLj\ncNzPBNpclllzHbmTNRhqCRTgjC\nnhhWJzhGPlQcGvsvfJtSfZfrtt\nPSzrBWQBBGzBlnSnWtDrqHfNfwVwHcLNjHjwcDNmFH\nhbRhtRCRpRvsRgVVVcNHNNNCwLwc\nZtRTRvttWWzBPlGZ\ntcLnctNsJrWWNDTN\npwPPSjHSHHfzvmSvvvFVVGqGVqGmFqrDWgDr\npPSvfPQMzCQCSbhllLnQDhbtQZ\nDmLffDhpVhjjVwvbwNVFbbNSNH\nJRPBgMPRHBrMHMHqrBMqWJBSQQNbCvndNrdvCNCFwFrQnv\nWcqJcPGMGtWRRBtgZjjspGHTLHGHTppm\nptJtWJpqRwDZZDVWpbDWqlvvflfMjlfCMjdCCdtslv\nrLwTBGBzBBQTzmwCCjvdvlLllddsMl\nNBwTmrGNgrTrcgPpWgWPDSVVPW\nCdglMnrlSSqDPpcsZb\nccwmVJtvVvVtNhBpBFPDVpqbbD\nTRGQjJjGTmtrTCgHWLfrcn\nJNNhLwWwWQHNPDmmjHpc\nzMqZCvVCSMVqMSTVvZVGsBnlslpmsmzlPmsHPsPB\nqTVqrgdCCbhfHJQFtg\nwNwCBBCZsfQWfmLCGSmmFRGSSF\nzjnPHPVqMhhZLTcbpbSncp\nlVlhlgzlPZlwtgBddJdfvf\nJWRWRRLWJLnjtjnLzGzznflBvfPvPMqMDqdbzblCzC\nTTScTVbHmTsVFrmcsgcHFlPMMvlvrDPdlrDDqdldvl\nbVpcpchgsFZHbhSmSTsHFFjwtZjnjLttntNjLjNLWtjw\nrffjPJzWzrgPpGWHVNqTtmqFTVRH\ncswhvlLBvSLsCtbFccmqVFNTbb\nwwZSCZSnCLsSDGgDmpGnfmmr\nrTfJTNtjfNljlrWSlzRtNlTqsddwGnsnHHwwhssTsnqw\nVpbpZZbvPLbZbbBhwqMHhsGMnJdVwV\nmgQZJDLBJbbbcbgZClCSfWlrCjRjlDCR\nfSpwcVfzsztcSSWNNMbnMRqTvtTv\nmJFmGDDDhGhBJHCQddllqTvCllqTRRWNnMbT\nFdFDGdDDDhhHdZDjhDmpwSPVZszpwZsVgsPRZs\n\u{0000}")

  (func $main (export "_start")
    (call $solve)
    (call $print_int_backwards)
  )

  (func $get_length_of_line (param $str_i i32) (result i32)
    (local $len i32)
    (loop $loop
      (call $getc (local.get $str_i))
      (i32.ne (i32.const 10)) ;; newline
      (if ;; it's not a newline
        (then
          (local.set $len (i32.add (i32.const 1) (local.get $len)))
          (local.set $str_i (i32.add (i32.const 1) (local.get $str_i)))
          br $loop))
    )
    (local.get $len)
  )

  (func $solve (result i64)
    (local $str_i i32)
    (local $line_begin i32)
    (local $sum i64)
    (local $bitfield i64)
    (local $line_len i32)
    (local $half_line_len i32)

    (loop $line_loop
      (local.set $line_begin (local.get $str_i))
      
      (call $get_length_of_line (local.get $str_i))
      (local.set $line_len)


      (local.set $half_line_len
        (i32.div_s (local.get $line_len) (i32.const 2)))

      (local.set $bitfield (i64.const 0))

      ;; from str_i to half_line_len, add to the bitmap
      (loop $first_half_loop
        (call $priority (call $getc (local.get $str_i)))
        (call $2_to_the_n)
        (i64.or (local.get $bitfield))
        (local.set $bitfield)
        (local.set $str_i (i32.add (local.get $str_i) (i32.const 1)))
        (br_if $first_half_loop
          (i32.lt_s
            (i32.sub (local.get $str_i) (local.get $line_begin))
            (local.get $half_line_len)))
      )

      (loop $second_half_loop
        (call $priority (call $getc (local.get $str_i)))
        (call $2_to_the_n)
        (i64.and (local.get $bitfield))
        (if (i64.ne (i64.const 0)) ;; means it's in the bitmap
          ;; then add the priority to the sum
          (then
            (local.set $sum
               (i64.add (call $priority (call $getc (local.get $str_i)))
                        (local.get $sum)))
          )
          (else
            (local.set $str_i (i32.add (local.get $str_i) (i32.const 1)))
            (br $second_half_loop)
          )
        )
      )

      (i32.add (i32.const 1) (local.get $line_len))
      (local.set $str_i (i32.add (local.get $line_begin)))
      (i32.ne (call $getc (local.get $str_i)) (i32.const 0))
      (br_if $line_loop)
    )

    (local.get $sum)
  )

  (func $2_to_the_n (param $n i64) (result i64)
    (i64.shl (i64.const 1) (local.get $n))
  )

  (func $priority (param $char i32) (result i64)
    ;; 'a' is 97, 'z' is 122
    (i32.and (i32.ge_s (local.get $char) (i32.const 97))
             (i32.le_s (local.get $char) (i32.const 122)))
    (if
      (then
        ;; priorities a - z are 1 - 26
        (i64.extend_i32_s (i32.sub (local.get $char) (i32.const 96)))
        return))

    ;; priorities A - Z are 27-52
    (i64.extend_i32_s (i32.sub (local.get $char) (i32.const 38)))
  )

  ;; reads an int from the input
  (func $readint (param $start_pos i32) (param $len i32) (result i64)
    (call $atoi
      (i32.add (i32.const 28) (local.get $start_pos))
      (local.get $len)
    )
  )

  (func $getc (param $i i32) (result i32)
    ;; beginning of string is 28
    (i32.load8_u (i32.add (i32.const 28) (local.get $i)))
  )

  (func $putc (param $c i32)
    ;; 12 is where the output goes

    ;; technically we only need to do this once, not every time
    ;; we print a char, but whatever we're debugging
    ;; Creating a new io vector within linear memory
    ;; memory offset of string
    (i32.store (i32.const 4) (i32.const 12))
    ;; length of string
    (i32.store (i32.const 8) (i32.const 1))

    (i32.store (i32.const 12) (local.get $c))

    (call $fd_write
      (i32.const 1) ;; fd 1 -- stdout
      (i32.const 4) ;; *iovs - The pointer to the iov array
      (i32.const 1) ;; iovs_len 
      (i32.const 0) ;; nwritten 
    )
    drop ;; nwritten
  )

  (func $print_int_backwards (param $num i64)
    (loop $loop
      (i64.rem_s (local.get $num) (i64.const 10))

      (i64.add (i64.const 48))
      (i32.wrap_i64)
      (call $putc)

      ;; divide input by 10
      (local.set $num (i64.div_s (local.get $num) (i64.const 10)))

      (i64.gt_s (local.get $num) (i64.const 0))
      br_if $loop
    )

    ;; print a newline
    (call $putc (i32.const 10))
  )

  ;; length is 4
  ;; offset is 3
  ;;
  ;; 1234
  (func $atoi (param $addr i32) (param $size i32) (result i64)
    ;; loop counter -- starts at 0
    (local $i i32)
    (local $acc i64)

    (loop $loop
      ;; multiply result by 10
      (i64.mul (local.get $acc) (i64.const 10))
      (local.set $acc)

      ;; push next char onto the stack
      (i32.add (local.get $addr) (local.get $i))
      (i64.load8_u)
      (i64.sub (i64.const 48))
      (i64.add (local.get $acc))
      (local.set $acc)

      ;; incr loop counter
      (local.set $i (i32.add (i32.const 1) (local.get $i)))
      (i32.lt_s (local.get $i) (local.get $size))
      br_if $loop
    )
    (local.get $acc)
  )
)
