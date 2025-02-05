module nfttest::nfttest {
    use std::bcs;
    use std::signer;
    use std::string::{Self, String};

    use aptos_token::token;
    use aptos_token::token::TokenDataId;

    struct ModuleData has key {
        token_data_id: TokenDataId,
    }

    const ENOT_AUTHORIZED: u64 = 1;

    fun init_module(source_account: &signer) {
        let collection_name = string::utf8(b"testing9");
        let description = string::utf8(b"Description");
        let collection_uri = string::utf8(b"https://www.csusm.edu/");
        let token_name = string::utf8(b"Token name");
        let token_uri = string::utf8(b"https://www.csusm.edu/communications/images/branding-images/spirit-logo01.jpg");

        token::create_collection(source_account, collection_name, description, collection_uri, 0, vector<bool>[false, false, false]);

        let token_data_id = token::create_tokendata(
            source_account,
            collection_name,
            token_name,
            string::utf8(b""),
            0,
            token_uri,
            signer::address_of(source_account),
            1,
            0,
            
            token::create_token_mutability_config(
                &vector<bool>[ false, false, false, false, true ]
            ),

            vector<String>[
                string::utf8(b"creator"),
                string::utf8(b"image_url") 
            ],
            vector<vector<u8>>[
                bcs::to_bytes(&signer::address_of(source_account)),
                bcs::to_bytes(&string::utf8(b"https://www.csusm.edu/communications/images/branding-images/spirit-logo01.jpg"))
            ],
            vector<String>[ string::utf8(b"address"), string::utf8(b"url") ],
        );

        move_to(source_account, ModuleData {
            token_data_id,
        });
    }

    public entry fun mint_one_to_sender(receiver: &signer) acquires ModuleData {
        let module_data = borrow_global_mut<ModuleData>(@nfttest);

        let token_id = token::mint_token(receiver, module_data.token_data_id, 1);
        token::direct_transfer(receiver, receiver, token_id, 1);

        let (creator_address, collection, name) = token::get_token_data_id_fields(&module_data.token_data_id);
        token::mutate_token_properties(
            receiver,
            signer::address_of(receiver),
            creator_address,
            collection,
            name,
            0,
            1,
            vector<String>[
                string::utf8(b"minted_by"),
                string::utf8(b"image_url")
            ],
            vector<vector<u8>>[
                bcs::to_bytes(&signer::address_of(receiver)),
                bcs::to_bytes(&string::utf8(b"https://www.csusm.edu/communications/images/branding-images/spirit-logo01.jpg"))
            ],
            vector<String>[ string::utf8(b"address"), string::utf8(b"url") ],
        );
    }

    public entry fun mint_amount_to_sender(account: &signer, num: u64) acquires ModuleData {
        let k:u64 = 0;
        while (k < num) {
            mint_one_to_sender(account);
            k = k + 1;
        }
    }
} 
