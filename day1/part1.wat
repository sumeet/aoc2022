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

  ;; TODO: implement strlen()
  ;; length of puzzle input is 10497, hardcoded
  ;; puzzle input
  (data (i32.const 28) "9195\n5496\n2732\n8364\n3703\n3199\n7177\n1659\n\n7307\n2177\n1011\n8678\n14080\n\n6465\n6922\n3733\n8573\n6749\n1704\n6429\n8774\n1296\n2536\n\n22456\n\n11642\n10162\n10997\n6963\n3076\n5859\n1280\n\n5285\n7498\n8540\n7360\n6822\n8042\n6798\n6398\n4495\n8043\n\n60304\n\n2947\n24880\n21239\n\n8441\n1034\n2591\n8993\n10366\n1313\n10497\n\n3404\n5018\n5377\n4783\n6441\n5110\n5688\n3371\n1220\n4949\n2945\n6041\n2852\n2379\n\n15514\n13699\n10357\n9769\n\n11464\n2001\n2847\n9933\n2706\n8621\n2064\n\n5478\n2981\n6540\n2303\n4607\n5284\n4762\n3936\n3194\n4371\n2925\n3124\n4491\n\n8542\n7605\n3773\n8575\n3405\n4720\n7857\n7427\n5182\n3977\n\n9405\n16048\n4142\n9101\n16303\n\n6102\n1795\n1053\n2091\n5774\n6053\n4997\n2109\n1019\n3830\n6057\n4772\n3344\n\n11299\n16115\n11748\n14944\n\n4477\n6292\n8257\n9583\n10416\n2730\n2153\n5887\n\n4790\n1198\n2184\n3604\n4004\n1543\n5017\n5409\n3489\n4731\n3302\n3046\n1056\n\n2260\n3028\n7305\n4516\n11415\n4855\n4297\n\n1669\n4175\n6403\n4004\n1711\n8509\n4874\n3756\n6893\n8463\n\n6333\n1576\n4576\n4288\n3764\n\n1831\n1336\n1579\n3704\n3215\n4702\n5798\n2714\n2917\n1616\n5564\n5061\n3188\n4473\n3457\n\n4140\n3428\n4274\n6158\n4641\n3009\n6576\n6065\n1912\n6539\n6603\n6519\n1765\n\n9606\n4903\n3424\n8196\n5996\n8874\n3223\n\n1220\n1823\n10789\n\n1268\n9582\n18617\n9647\n\n5024\n8920\n7746\n1641\n8120\n\n2531\n6027\n2332\n1138\n1623\n5812\n5445\n3289\n5476\n4366\n2108\n1557\n3495\n6402\n\n9408\n9279\n7150\n10907\n1672\n\n5314\n4022\n1005\n2246\n2362\n6739\n2988\n3694\n3827\n7027\n6688\n\n5328\n1002\n6230\n3178\n3214\n1388\n1377\n4036\n1138\n3142\n4432\n6435\n1004\n3330\n\n7157\n4529\n6804\n2866\n8358\n5096\n6279\n2843\n4766\n\n5901\n3567\n5658\n2691\n1274\n5522\n5166\n3121\n4019\n4943\n3075\n6363\n1481\n2265\n\n3859\n2225\n8342\n5976\n5027\n8056\n2568\n9185\n4977\n\n10439\n23445\n22928\n\n19540\n2027\n13612\n11009\n\n5729\n2779\n3998\n5445\n5873\n6582\n7603\n4737\n7269\n1552\n6875\n\n1281\n14848\n9048\n11497\n5727\n\n17791\n13209\n18978\n\n5137\n4552\n1608\n2501\n2700\n5797\n5238\n1814\n5319\n2401\n4549\n5636\n3334\n1848\n3434\n\n1844\n6371\n6522\n4006\n1587\n3280\n2227\n3655\n1463\n7113\n6222\n1535\n\n4030\n7221\n2228\n8901\n3291\n5507\n9136\n\n6160\n2512\n4825\n7461\n1360\n5137\n5950\n4281\n6156\n6455\n3709\n6824\n\n4851\n3122\n8946\n8309\n2777\n8658\n2167\n4599\n\n13020\n11487\n4852\n4141\n10771\n\n7617\n1953\n2917\n1490\n11333\n8366\n3536\n\n2129\n3570\n3584\n1128\n5877\n6076\n1131\n4300\n4587\n3900\n2032\n6108\n3500\n5816\n2367\n\n2321\n9945\n7736\n15720\n\n4709\n5471\n4445\n1162\n5062\n4576\n3316\n3568\n4556\n4169\n5592\n2290\n1301\n4286\n\n6357\n2925\n3527\n6451\n4206\n3113\n3371\n5688\n5965\n5569\n2426\n3498\n\n4785\n3391\n4721\n3860\n4591\n3316\n3906\n4096\n3114\n3084\n5587\n2387\n4083\n3156\n5375\n\n18007\n13252\n8010\n11758\n\n4133\n4727\n6565\n2361\n4219\n6926\n7563\n2415\n1503\n2280\n\n2590\n4700\n6754\n3719\n1385\n6642\n5342\n6977\n6863\n5943\n5963\n\n9743\n5874\n2287\n1349\n9400\n\n1833\n3455\n4682\n5001\n1194\n4009\n6100\n2669\n2387\n3677\n5969\n5675\n5043\n2851\n1510\n\n6344\n7947\n4455\n11855\n12264\n\n7307\n5381\n2683\n5690\n3800\n7294\n6155\n3818\n2147\n6822\n1791\n6219\n\n5720\n7820\n1697\n8666\n4561\n2786\n\n5502\n3231\n2121\n6771\n5496\n4354\n2459\n5300\n1012\n4840\n2244\n2257\n5116\n\n6483\n5654\n2132\n1533\n3053\n2037\n2813\n3266\n1113\n3421\n4371\n3298\n1083\n3178\n\n5702\n5532\n3500\n10461\n1388\n10833\n\n3275\n2980\n7734\n3164\n4787\n9609\n2479\n3653\n6775\n\n32754\n\n10713\n2913\n2073\n2390\n4035\n5313\n\n2154\n2932\n3665\n2209\n4770\n5509\n4867\n1077\n1042\n5075\n1468\n2559\n5969\n4421\n3097\n\n10940\n\n1790\n3782\n5620\n3929\n8752\n3616\n4303\n5242\n4985\n3153\n\n2056\n5738\n6082\n2290\n4491\n3540\n4606\n5400\n1950\n4392\n3358\n3965\n1015\n4747\n4146\n\n6837\n1403\n7490\n9041\n1880\n7983\n7951\n3991\n\n3812\n8432\n5534\n10149\n6927\n5737\n7757\n6755\n\n24486\n17671\n3275\n\n5835\n5716\n3114\n4794\n6131\n3155\n5121\n4263\n2172\n1250\n4699\n3474\n2422\n1112\n\n2228\n3141\n8939\n2339\n1934\n5567\n4386\n4608\n4715\n\n5667\n4951\n1903\n3770\n3604\n3358\n3431\n5347\n1549\n6035\n1213\n2966\n5881\n2159\n5931\n\n1855\n2610\n3721\n1186\n1476\n5566\n5896\n5461\n2244\n6439\n2996\n4877\n\n3605\n8024\n1015\n2396\n6499\n5491\n6897\n1527\n3023\n3733\n1569\n\n4818\n5057\n\n5425\n4529\n1806\n4492\n3824\n6389\n2425\n1938\n6364\n3319\n2590\n3288\n3213\n6375\n\n19548\n2710\n\n2339\n6807\n4818\n6364\n1582\n4337\n2672\n2010\n2158\n4945\n4497\n6038\n6384\n\n6358\n24928\n\n2269\n7157\n7539\n4229\n5439\n7720\n5840\n5121\n\n1874\n4557\n1240\n\n20698\n32960\n\n6631\n6168\n7092\n3064\n1584\n4665\n7038\n5025\n4993\n4444\n3237\n6476\n\n9475\n8971\n8493\n12321\n8494\n13681\n\n5753\n3191\n3239\n2583\n1752\n6646\n2353\n9605\n9421\n\n6201\n2996\n5305\n3353\n4674\n6344\n3090\n7267\n7553\n3036\n\n4230\n1261\n4167\n7900\n7309\n1072\n2156\n7061\n1072\n3936\n5478\n\n2149\n5822\n6544\n4842\n3460\n6259\n3309\n6826\n8189\n\n5224\n9962\n8680\n8700\n5705\n9423\n9132\n\n10634\n5810\n7278\n7563\n4692\n9359\n10970\n\n2265\n5518\n4578\n2087\n5530\n2822\n3506\n5354\n3795\n6447\n7721\n\n5983\n4123\n11142\n5380\n9873\n\n6575\n3055\n1253\n3073\n3428\n5034\n5026\n2078\n2305\n1243\n1741\n1905\n3417\n\n7507\n3916\n12542\n3336\n13205\n9414\n\n2572\n3152\n4829\n4925\n2805\n2109\n2479\n5310\n2369\n3676\n3808\n2061\n2103\n3846\n\n2228\n2731\n3042\n7005\n2663\n5092\n5604\n5128\n2481\n6335\n6596\n1590\n\n17388\n\n1907\n9742\n2574\n5867\n1944\n9382\n7215\n4615\n\n7022\n17033\n18410\n9549\n\n12399\n14254\n7540\n14639\n\n6076\n1520\n5371\n6776\n3480\n2872\n2754\n3560\n4076\n7127\n4847\n\n28413\n29243\n\n6331\n\n1295\n7963\n7819\n8935\n4932\n2119\n8965\n\n4020\n1815\n4975\n4252\n3814\n3944\n4046\n5322\n4492\n6798\n7873\n\n22718\n15596\n3783\n\n2540\n1228\n6529\n8255\n8380\n7381\n5272\n4335\n9079\n\n13674\n\n4654\n14973\n\n9742\n7320\n6104\n10643\n2218\n3849\n1554\n6240\n\n5883\n\n2947\n3960\n3137\n3545\n4086\n3281\n2125\n2187\n2672\n6083\n6348\n5979\n\n3978\n13338\n6730\n11223\n\n10774\n8045\n3517\n5539\n\n3497\n3723\n5012\n2253\n6525\n6164\n5048\n3048\n3572\n4049\n4332\n\n10141\n5326\n1095\n2973\n5927\n2007\n2050\n\n3706\n2393\n7466\n6424\n3406\n6692\n6659\n5887\n2430\n1710\n\n2477\n10590\n7756\n6758\n7119\n2697\n7582\n2818\n\n7797\n3364\n12741\n13118\n8536\n11425\n\n1233\n7736\n7864\n9042\n1637\n10294\n\n24161\n9656\n18425\n\n5990\n2101\n5653\n2884\n3039\n4797\n5843\n5247\n1273\n5886\n6625\n6674\n\n6329\n18772\n2093\n17934\n\n4887\n6312\n3128\n3886\n3463\n4255\n3756\n3983\n3426\n1431\n2698\n6393\n1005\n4468\n\n5205\n33136\n\n6347\n4976\n1837\n2668\n1958\n2844\n1832\n5159\n6743\n5235\n2063\n6345\n5435\n\n8099\n7958\n1005\n6197\n5256\n5473\n5305\n6725\n8345\n7710\n\n3872\n6145\n9624\n2956\n8435\n10422\n\n3327\n8232\n3193\n10317\n8307\n3668\n1460\n\n1846\n\n8278\n3383\n2806\n8824\n2203\n7408\n8406\n9472\n\n4239\n4975\n2739\n5971\n6296\n1441\n3258\n4039\n1250\n6148\n4268\n1029\n4749\n\n13122\n16097\n24603\n\n16731\n\n9483\n5982\n1713\n3420\n8734\n3700\n7331\n6766\n8751\n\n8615\n5515\n2095\n6447\n2271\n5116\n4192\n2466\n6024\n7381\n\n5890\n1229\n5991\n6171\n1006\n8052\n1047\n2854\n6775\n\n2707\n4168\n3672\n5598\n6167\n1829\n1057\n4637\n4838\n1436\n3420\n\n11809\n3398\n5077\n7486\n8465\n13335\n\n7603\n2418\n5080\n6220\n11293\n3620\n2269\n\n3091\n1168\n6766\n1451\n5970\n6730\n4050\n4668\n1481\n5796\n1761\n2176\n6819\n\n11912\n11768\n10317\n7266\n7893\n5171\n10226\n\n3050\n16374\n8289\n10976\n5718\n\n6761\n7838\n13450\n7109\n4241\n\n5966\n10730\n10359\n1504\n7420\n5282\n8409\n3601\n\n12221\n9545\n19251\n\n8255\n13820\n\n2603\n2664\n6910\n3057\n3028\n3978\n5942\n1761\n7094\n4810\n6613\n3734\n\n1682\n6879\n4558\n5580\n7138\n1357\n6509\n1608\n\n10454\n6353\n9343\n5446\n10576\n4785\n10603\n10093\n\n4608\n5849\n5198\n6198\n6657\n4876\n4557\n4176\n4300\n2296\n6147\n5391\n2029\n\n57604\n\n9413\n8063\n7537\n6320\n1097\n6122\n1355\n4272\n\n3874\n17796\n15560\n14745\n\n2035\n7677\n3549\n7187\n5545\n8078\n7619\n1164\n4781\n1537\n1300\n\n4958\n3527\n5457\n2429\n4177\n3722\n2678\n2858\n3860\n2757\n1652\n3601\n1271\n5064\n4825\n\n1451\n5344\n9505\n3578\n5125\n3601\n7753\n9647\n5199\n\n1023\n2994\n3314\n2984\n1823\n1049\n1451\n4002\n1982\n1991\n5607\n2280\n2637\n\n10085\n1558\n4129\n16879\n\n4014\n1850\n1953\n1210\n6063\n1152\n1155\n5688\n2564\n2601\n4987\n3243\n5028\n3031\n4566\n\n5269\n3381\n6856\n3425\n4686\n7142\n3527\n5679\n1170\n1974\n5245\n\n3188\n2577\n5091\n4836\n8051\n9506\n4796\n6060\n2312\n\n1174\n2702\n2957\n2060\n2298\n3065\n4107\n5288\n8035\n1408\n1220\n\n7531\n28620\n\n5642\n9226\n4661\n8001\n3130\n2765\n8861\n5388\n8664\n\n38986\n\n5940\n1905\n2903\n4936\n1631\n3601\n3904\n5472\n4605\n4450\n1924\n5819\n5595\n2620\n4949\n\n2678\n4645\n7836\n9040\n6883\n5728\n\n30287\n\n7177\n8034\n9715\n5392\n2758\n3528\n2237\n3861\n\n3185\n4171\n2020\n4715\n7052\n2755\n1914\n7742\n\n1707\n1676\n5745\n4143\n4923\n5895\n4430\n3479\n5577\n4055\n5398\n3686\n3102\n\n2210\n7100\n7893\n18459\n\n10383\n36815\n\n5724\n7580\n5795\n2420\n6769\n2653\n11300\n\n64590\n\n1458\n2116\n2482\n1405\n5244\n2676\n3142\n5465\n1204\n3386\n2346\n5280\n4419\n5141\n1792\n\n15148\n9248\n10159\n15310\n10409\n\n6717\n8383\n3815\n4003\n3628\n1330\n3935\n7421\n8104\n6368\n\n4427\n12621\n4678\n\n8039\n2837\n3527\n7261\n1895\n1730\n2425\n9351\n4956\n\n4754\n3919\n7834\n1825\n9221\n2448\n6332\n6027\n\n2762\n8800\n2052\n6914\n4855\n5555\n5457\n7150\n\n4929\n9391\n2475\n3274\n11392\n6243\n10749\n\n9936\n2900\n11200\n8301\n8740\n1807\n9313\n\n7654\n6957\n3503\n1388\n3461\n8003\n8540\n8588\n6578\n5105\n\n2375\n2789\n4492\n9766\n6242\n8573\n7746\n2312\n\n18293\n7456\n12739\n14503\n\n4591\n5244\n2190\n1492\n3205\n4797\n4072\n5747\n2280\n3726\n2871\n2903\n3336\n2136\n4352\n\n1198\n7124\n7138\n1289\n7137\n3365\n3758\n3462\n1829\n5959\n4767\n5007\n\n61923\n\n35790\n17566\n\n61494\n\n6184\n1939\n4155\n6792\n4221\n5606\n5012\n2653\n6955\n4262\n7482\n\n8406\n8532\n17249\n14475\n\n2836\n5515\n1600\n5230\n2379\n1581\n2792\n4921\n1706\n5905\n4341\n4541\n2423\n1089\n3865\n\n10178\n7282\n4389\n1368\n6403\n4864\n9894\n1600\n\n14638\n17362\n1290\n13364\n\n9732\n4333\n6164\n3377\n10073\n\n3421\n5867\n4088\n3939\n2340\n1172\n5329\n1353\n1760\n2609\n2241\n3184\n4067\n3187\n\n1251\n10075\n5029\n11495\n16420\n\n9941\n1159\n6581\n5359\n5091\n9709\n6879\n1480\n\n8735\n7340\n7533\n7967\n3090\n4415\n8030\n2024\n7643\n1020\n\n3683\n1827\n4572\n4920\n5321\n6344\n7409\n6644\n5261\n5461\n4746\n2427\n\n1933\n3844\n4152\n7816\n4841\n9773\n8031\n4562\n\n5859\n5820\n2404\n4008\n6263\n5126\n6608\n4376\n1742\n4257\n3698\n6355\n6830\n\n12023\n\n13405\n17282\n4233\n\n1854\n3016\n5622\n4353\n4201\n1603\n6425\n5189\n5954\n4672\n4166\n6254\n2946\n5488\n\n25849\n\n5724\n1798\n4680\n3686\n\n2487\n\n4242\n6224\n5721\n4919\n6956\n2243\n2558\n5831\n4442\n5899\n5110\n3296\n3166\n\n8097\n6087\n3812\n8427\n2519\n2596\n8032\n5217\n5404\n1761\n\n1051\n8900\n3355\n8481\n10567\n9593\n9889\n1111\n\n2421\n7635\n1078\n10224\n3394\n8259\n6023\n\n1746\n3725\n5398\n1283\n6522\n5172\n2666\n4207\n3608\n4554\n3320\n3092\n\n12151\n2380\n2379\n9460\n2103\n2719\n\n4111\n4047\n5566\n1533\n3013\n1914\n6732\n3081\n3039\n2544\n1602\n\n1944\n7139\n1270\n3971\n1754\n5539\n7134\n2383\n7875\n6814\n3154\n\n6658\n6937\n5130\n12523\n2510\n13475\n\n8220\n14140\n16575\n17834\n\n30821\n27376\n\n6988\n1239\n3428\n9314\n12372\n6311\n\n1230\n7470\n5818\n2628\n2076\n4683\n6782\n6631\n5341\n3207\n2733\n\n3007\n4564\n3184\n7193\n6232\n6808\n1125\n1167\n5083\n5500\n1501\n\n12528\n6660\n5956\n4124\n15907\n\n4341\n3095\n5140\n2053\n2632\n4026\n6882\n1575\n2699\n1134\n6729\n3741\n1965\n\n40377\n\n7974\n32804\n\n6933\n17986\n\n3950\n8994\n5969\n5927\n9676\n4722\n2511\n3924\n\n8550\n5279\n4462\n1898\n4285\n8152\n7672\n6239\n7171\n6077\n\n4648\n3574\n3766\n1602\n5875\n2697\n2112\n2269\n5661\n5173\n5412\n3064\n2152\n2421\n3606\n\n19130\n24395\n6811\n\n14914\n5386\n17927\n\n57004\n\n6847\n2293\n3144\n6966\n3591\n6579\n6282\n7983\n2019\n5166\n\n25773\n21289\n3985\n\n18580\n10900\n12012\n\n20434\n\n6523\n17040\n7830\n\n15328\n3273\n17137\n14101\n\n25430\n\n5245\n1411\n3633\n1296\n4017\n4795\n3146\n6096\n3424\n\n2996\n\n3496\n12598\n7602\n6914\n2027\n1459\n\n5307\n4932\n8654\n5673\n8580\n3054\n7353\n6379\n\n5347\n5969\n8241\n8710\n1345\n5500\n2640\n1101\n\n10640\n5177\n6497\n5013\n6210\n8109\n9250\n1643\n\n23753\n1998\n16905\n\n34219\n25863\n\n5926\n8576\n4565\n2605\n11086\n10217\n3411\n\n4970\n1205\n3186\n5837\n3119\n7356\n4392\n5270\n2521\n2452\n5271\n2905\n\n4054\n8657\n9202\n6213\n4409\n4695\n\n3198\n7002\n15731\n5099\n16321\n\n14542\n\n39972\n\n10785\n17115\n22811\n\n7214\n7178\n5198\n2157\n6985\n1686\n8037\n7559\n2410\n5211\n6477\n\n1496\n3607\n2326\n5342\n5777\n6182\n5528\n6324\n2023\n2944\n2175\n5035\n1424\n2154\n\n5224\n4172\n1295\n7929\n4386\n2421\n6034\n2895\n3881\n2464\n")

  (func $main (export "_start")
    ;; Creating a new io vector within linear memory
    ;; memory offset of string
    (i32.store (i32.const 0) (i32.const 28))
    ;; length of string
    (i32.store (i32.const 4) (i32.const 10497))

    (call $fd_write
      (i32.const 1) ;; fd - 1 for stdout
      ;; *iovs - The pointer to the iov array
      ;; which is stored at memory location 0
      (i32.const 0) 
      ;; iovs_len - We're printing 1 string stored in an iov 
      ;; so one.
      (i32.const 1) 
      (i32.const 0) ;; nwritten - A place in memory to store the number of bytes written
    )
    drop ;; Discard the number of bytes written from the top of the stack
  )

  (func $print_int_backwards (param $num i32)
    ;; 12 is where the output goes

    ;; Creating a new io vector within linear memory
    ;; memory offset of string
    (i32.store (i32.const 4) (i32.const 12))
    ;; length of string
    (i32.store (i32.const 8) (i32.const 1))

    (loop $loop
      (i32.rem_s (local.get $num) (i32.const 10))

      (i32.store (i32.const 12))

      (call $fd_write
        (i32.const 1)
        ;; *iovs - The pointer to the iov array
        (i32.const 4) 
        ;; iovs_len 
        (i32.const 1) 
        (i32.const 0) ;; nwritten 
      )
      drop ;; nwritten

      ;; divide input by 10
      (local.set $num (i32.div_s (local.get $num) (i32.const 10)))

      (i32.gt_s (local.get $num) (i32.const 0))
      br_if $loop
    )

    ;; print a newline
    (i32.store (i32.const 12) (i32.const 10)) ;; newline
    (call $fd_write
      (i32.const 1)
      ;; *iovs - The pointer to the iov array
      (i32.const 4) 
      ;; iovs_len 
      (i32.const 1) 
      (i32.const 0) ;; nwritten 
    )
    drop ;; nwritten
  )

  ;; length is 4
  ;; offset is 3
  ;;
  ;; 1234
  (func $atoi (param $addr i32) (param $size i32) (result i32)
    ;; loop counter -- starts at 0
    (local $i i32)
    (local $acc i32)

    (loop $loop
      ;; multiply result by 10
      (i32.mul (local.get $acc) (i32.const 10))
      (local.set $acc)

      ;; push next char onto the stack
      (i32.add (local.get $addr) (local.get $size))
      (i32.load8_u)
      (i32.sub (i32.const 48))
      (i32.add (local.get $acc))
      (local.set $acc)

      ;; incr loop counter
      (local.set $i (i32.add (i32.const 1) (local.get $i)))
      (i32.lt_s (local.get $i) (local.get $size))
      br_if $loop
    )
    (local.get $acc)
  )
)
