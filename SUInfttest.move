module nfttest::nfttest {
    use sui::url::{Self, Url};
    use std::string::{utf8, String};
    use sui::tx_context::sender;
    use sui::package;
    use sui::display;

    public struct MyNFT has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
        creator: address,
    }

    public struct NFTTEST has drop {}

    fun init(otw: NFTTEST, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];
        let values = vector[
            utf8(b"{name}"),
            utf8(b"{image_url}"),
            utf8(b"{description}"),
            utf8(b"https://www.csusm.edu/"),
            utf8(b"{creator}"),
        ];

        let publisher = package::claim(otw, ctx);
        let mut display = display::new_with_fields<MyNFT>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    public entry fun mint_amount_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        num: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let mut k:u64 = 0;
        while(k < num) {
            let nft = MyNFT {
                id: object::new(ctx),
                name: utf8(name),
                description: utf8(description),
                creator: sender(ctx),
                url: url::new_unsafe_from_bytes(url),
            };

            transfer::public_transfer(nft, sender);
            k = k + 1;
        }
    }
}
