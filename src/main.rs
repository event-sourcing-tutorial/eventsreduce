use events::Event;
use objects::{User, UserStatus};
use postgresql_reducer::{create, delete, fetch, start_reducing, update, Action, NOOP};

mod events; // shared between reducer and command processor
mod objects; // shared between reducer and command processor and broker

fn reduce(event: Event) -> Action {
    match event {
        Event::UserCreated { user_id } => create(
            &user_id,
            User {
                name: None,
                status: UserStatus::New,
                offers: vec![],
            },
        ),
        Event::UserNameUpdated { user_id, name } => fetch(&user_id.clone(), move |u: User| {
            update(&user_id, User { name, ..u })
        }),
        Event::UserDeleted { user_id } => delete::<User>(&user_id),
        Event::SomeOtherEvent {} => NOOP,
    }
}

fn main() {
    start_reducing(reduce);

    // let e0 = Event::UserCreated {
    //     user_id: "user1".to_string(),
    // };
    // let e1 = Event::UserNameUpdated {
    //     user_id: "user1".to_string(),
    //     name: Some("Aziz".to_string()),
    // };
    // let _a0 = reduce(e0.clone());
    // let _a1 = reduce(e1);
    // let u = User {
    //     name: Some("Foo".to_string()),
    //     status: UserStatus::GoodStanding,
    //     offers: vec!["X".to_string(), "y".to_string()],
    // };
    // let v = to_value(u).unwrap();
    // // let t = type_name::<User>();
    // let t = User::type_name();
    // println!("{} {}", t, v);
    // println!("{}", to_value(e0).unwrap());
}
